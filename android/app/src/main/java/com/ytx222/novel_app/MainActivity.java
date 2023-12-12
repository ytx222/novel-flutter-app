package com.ytx222.novel_app3;

import static android.content.Context.BATTERY_SERVICE;

// battery
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
// import io.flutter.app.FlutterActivity;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.GeneratedPluginRegistrant;

import androidx.annotation.NonNull;
//就是这个包,搜出来的都没有导入,但是官方文档有,
//还是优先看文档吧,虽然是英文,但是靠谱
import io.flutter.embedding.engine.FlutterEngine;

import java.util.ArrayList;
import java.util.List;


public class MainActivity extends FlutterActivity {

    // 是否需要拦截音量键
    static boolean volumeChangeObserver = true;

    protected MethodChannel channel;


    void send(String method, Object data) {
        channel.invokeMethod(method, data);
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (volumeChangeObserver) {
            switch (keyCode) {
                case KeyEvent.KEYCODE_VOLUME_UP: // 增大系统媒体音量
                    send("volumeChange", 1);
                    return true;
                case KeyEvent.KEYCODE_VOLUME_DOWN: // 减小系统媒体音量
                    send("volumeChange", 0);
                    return true;
                default:
                    break;
            }
        }
        return super.onKeyDown(keyCode, event);
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        /// 接受消息
        MethodCallHandler mch = new MethodCallHandler() {
            @Override
            public void onMethodCall(MethodCall call, Result result) {
				// call.method.equals("getBattery")判断dart调用的是什么方法
                Log.i("调用java方法",call.method);
                if (call.method.equals("getBattery")) {
                    // 获取电量
                    int batteryLevel = getBattery();
                    result.success(batteryLevel);
//                    int[] res = {batteryLevel, 0, 0};
                    List<Integer> res=new ArrayList<Integer>();
                    res.add(batteryLevel);
                    send("batteryChange", res);
                } else if (call.method.equals("setBatteryChangeObserver")) {
                    // 设置监听电量
                    Boolean _is = (Boolean) call.arguments;
                    if (_is) {
                        startBatteryChangeObserver();
                    } else {
                        endBatteryChangeObserver();
                    }
                    result.success(true);
                } else if (call.method.equals("setVolumeChangeObserver")) {
                    // 设置监听音量
                    Boolean _is = (Boolean) call.arguments;
                    volumeChangeObserver = _is;
                    result.success(true);
                } else {
                    result.notImplemented();
                }
            }
        };
        // initFlutterApi();
        channel = new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(),
                "com.ytx222.novel_app3.api");
		channel.setMethodCallHandler(mch);
		initBatteryChangeObserver();
    }

    /**
     * 监听电池电量和获取电池电量
     */

    // 获取电量
    private int getBattery() {
        int batteryLevel = -1;
        if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
            BatteryManager batteryManager = (BatteryManager) getSystemService(BATTERY_SERVICE);
            batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY);
        } else {
            Intent intent = new ContextWrapper(getApplicationContext()).registerReceiver(null,
                    new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
            batteryLevel = (intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100)
                    / intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1);
        }
        return batteryLevel;
    }

    private BroadcastReceiver mReceiver;
	private IntentFilter mFilter;

	void initBatteryChangeObserver() {
		mFilter = new IntentFilter();
        // 监听电量变化，只能采用动态注册方式，不能在AndroidManifest.xml中用静态注册广播接受者
        mFilter.addAction(Intent.ACTION_BATTERY_CHANGED);
        mReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                // 当前电量
                int level = intent.getIntExtra(BatteryManager.EXTRA_LEVEL, 0);
                // 最大电量
                int scale = intent.getIntExtra(BatteryManager.EXTRA_SCALE, 0);
                // 百分比
                int value = (level * 100) / scale;
                List<Integer> res=new ArrayList<Integer>();
                res.add(value);
                res.add(level);
                res.add(scale);
                // 返回数据
                send("batteryChange", res);
            }
        };
	}

    // 开始监听
    void startBatteryChangeObserver() {
		registerReceiver(mReceiver, mFilter);
    }

    // 结束监听
    void endBatteryChangeObserver() {
        mReceiver.clearAbortBroadcast();
        unregisterReceiver(mReceiver);
    }

}
