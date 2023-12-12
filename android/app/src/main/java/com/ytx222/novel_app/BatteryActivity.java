package com.ytx222.novel_app3;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.os.Bundle;

import java.util.ArrayList;
import java.util.List;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.embedding.engine.FlutterEngine;
import androidx.annotation.NonNull;

public class BatteryActivity extends FlutterActivity {
	private BroadcastReceiver mReceiver;
	private IntentFilter mFilter;

	protected MethodChannel channel;

	void send(String method, Object data) {
		channel.invokeMethod(method, data);
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		///
		/// 接受消息
//		MethodCallHandler mch = new MethodCallHandler() {
//			@Override
//			public void onMethodCall(MethodCall call, Result result) {
//				// call.method.equals("getBattery")判断dart调用的是什么方法
//				if (call.method.equals("getBattery")) {
//					// 获取电量
//					int batteryLevel = getBattery();
//					result.success(batteryLevel);
////                    int[] res = {batteryLevel, 0, 0};
//					List<Integer> res=new ArrayList<Integer>();
//					res.add(batteryLevel);
//					send("batteryChange", res);
//				} else if (call.method.equals("setBatteryChangeObserver")) {
//					// 设置监听电量
//					Boolean _is = (Boolean) call.arguments;
//					if (_is) {
//						startBatteryChangeObserver();
//					} else {
//						endBatteryChangeObserver();
//					}
//					result.success(true);
//				} else if (call.method.equals("setVolumeChangeObserver")) {
//					// 设置监听音量
//					Boolean _is = (Boolean) call.arguments;
//					volumeChangeObserver = _is;
//					result.success(true);
//				} else {
//					result.notImplemented();
//				}
//			}
//		};
		// initFlutterApi();
		channel = new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(),
				"com.ytx222.novel_app3.api");
//		channel.setMethodCallHandler(mch);
		///
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
//                int[] res = {value, scale, level};
				// 返回数据
				send("batteryChange", res);
			}
		};
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
		unregisterReceiver(mReceiver);
	}
}
