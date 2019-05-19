package net.ottomated.snapchat;

import android.app.Activity;
import android.text.TextUtils;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

import com.snapchat.kit.sdk.SnapCreative;
import com.snapchat.kit.sdk.SnapLogin;
import com.snapchat.kit.sdk.core.controller.LoginStateController;
import com.snapchat.kit.sdk.creative.api.SnapCreativeKitApi;
import com.snapchat.kit.sdk.creative.exceptions.SnapMediaSizeException;
import com.snapchat.kit.sdk.creative.exceptions.SnapStickerSizeException;
import com.snapchat.kit.sdk.creative.exceptions.SnapVideoLengthException;
import com.snapchat.kit.sdk.creative.media.SnapMediaFactory;
import com.snapchat.kit.sdk.creative.media.SnapPhotoFile;
import com.snapchat.kit.sdk.creative.media.SnapSticker;
import com.snapchat.kit.sdk.creative.media.SnapVideoFile;
import com.snapchat.kit.sdk.creative.models.SnapContent;
import com.snapchat.kit.sdk.creative.models.SnapLiveCameraContent;
import com.snapchat.kit.sdk.creative.models.SnapPhotoContent;
import com.snapchat.kit.sdk.creative.models.SnapVideoContent;
import com.snapchat.kit.sdk.login.models.MeData;
import com.snapchat.kit.sdk.login.models.UserDataResponse;
import com.snapchat.kit.sdk.login.networking.FetchUserDataCallback;
import com.snapchat.kit.sdk.util.SnapUtils;

/**
 * SnapchatPlugin
 */
public class SnapchatPlugin implements MethodCallHandler, LoginStateController.OnLoginStateChangedListener {
    private Activity _activity;
    private MethodChannel.Result _result;
    private SnapCreativeKitApi creativeApi;
    private SnapMediaFactory mediaFactory;

    private SnapchatPlugin(Activity activity) {
        this._activity = activity;
    }

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "snapchat");
        channel.setMethodCallHandler(new SnapchatPlugin(registrar.activity()));
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        switch (call.method) {
            case "installed":
                boolean isInstalled = SnapUtils.isSnapchatInstalled(_activity.getPackageManager(), "com.snapchat.android");
                result.success(isInstalled);
                break;
            case "login":
                SnapLogin.getLoginStateController(_activity).addOnLoginStateChangedListener(this);
                SnapLogin.getAuthTokenManager(_activity).startTokenGrant();
                this._result = result;
                break;
            case "logout":
                SnapLogin.getLoginStateController(_activity).removeOnLoginStateChangedListener(this);
                SnapLogin.getAuthTokenManager(_activity).revokeToken();
                this._result = result;
                break;
            case "send":
                initCreativeApi();
                this._result = result;
                String type = call.argument("mediaType");
                assert type != null;
                String path = call.argument("path");

                SnapContent content;
                if (type.equals("Photo"))
                    content = getImage(path);
                else if (type.equals("Video"))
                    content = getVideo(path);
                else
                    content = getLive();
                if (content == null) return;

                if (call.argument("caption") != null)
                    content.setCaptionText((String) call.argument("caption"));

                if (call.argument("attachment") != null)
                    content.setAttachmentUrl((String) call.argument("attachment"));

                Map<String, Object> stickerMap = call.argument("sticker");
                if (stickerMap != null) {
                    assert stickerMap.get("path") != null;
                    SnapSticker sticker;
                    try {
                        sticker = mediaFactory.getSnapStickerFromFile(new File((String) stickerMap.get("path")));
                    } catch (SnapStickerSizeException e) {
                        _result.error("400", e.getMessage(), null);
                        return;
                    }
                    if (stickerMap.get("width") != null)
                        sticker.setWidth(((Double) stickerMap.get("width")).floatValue());
                    if (stickerMap.get("height") != null)
                        sticker.setHeight(((Double) stickerMap.get("height")).floatValue());
                    if (stickerMap.get("x") != null)
                        sticker.setPosX(((Double) stickerMap.get("x")).floatValue());
                    if (stickerMap.get("y") != null)
                        sticker.setPosY(((Double) stickerMap.get("y")).floatValue());
                    if (stickerMap.get("rotation") != null)
                        sticker.setRotationDegreesClockwise(((Double) stickerMap.get("rotation")).floatValue());
                    content.setSnapSticker(sticker);
                }
                creativeApi.send(content);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private void initCreativeApi() {
        if (creativeApi == null) creativeApi = SnapCreative.getApi(_activity);
        if (mediaFactory == null) mediaFactory = SnapCreative.getMediaFactory(_activity);
    }

    private SnapPhotoContent getImage(String path) {

        SnapPhotoFile photoFile;
        try {
            photoFile = mediaFactory.getSnapPhotoFromFile(new File(path));
        } catch (SnapMediaSizeException e) {
            _result.error("400", e.getMessage(), null);
            return null;
        }
        return new SnapPhotoContent(photoFile);
    }

    private SnapVideoContent getVideo(String path) {

        SnapVideoFile videoFile;
        try {
            videoFile = mediaFactory.getSnapVideoFromFile(new File(path));
        } catch (SnapMediaSizeException | SnapVideoLengthException e) {
            _result.error("400", e.getMessage(), null);
            return null;
        }
        return new SnapVideoContent(videoFile);
    }

    private SnapLiveCameraContent getLive() {
        return new SnapLiveCameraContent();
    }

    private void fetchUserData() {
        String query = "{me{bitmoji{avatar},displayName,externalId}}";
        SnapLogin.fetchUserData(_activity, query, null, new FetchUserDataCallback() {
            @Override
            public void onSuccess(UserDataResponse userDataResponse) {
                if (userDataResponse == null || userDataResponse.getData() == null) {
                    return;
                }

                MeData meData = userDataResponse.getData().getMe();
                if (meData == null) {
                    _result.error("400", "Error in login", null);
                    return;
                }
                Map<String, Object> data = new HashMap<>();
                data.put("id", meData.getExternalId());

                data.put("displayName", meData.getDisplayName());

                if (meData.getBitmojiData() != null) {
                    if (!TextUtils.isEmpty(meData.getBitmojiData().getAvatar())) {
                        data.put("bitmoji", meData.getBitmojiData().getAvatar());
                    }
                }
                _result.success(data);

            }

            @Override
            public void onFailure(boolean isNetworkError, int statusCode) {
                _result.error("400", "Error in login", null);
            }
        });
    }

    @Override
    public void onLoginSucceeded() {
        fetchUserData();
    }

    @Override
    public void onLoginFailed() {
    }

    @Override
    public void onLogout() {
        _result.success("logout");
    }
}
