import 'package:flutter/material.dart';

class LoadingUtil {
  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;

  /// 显示Loading
  static void show(BuildContext context, {String? message}) {
    if (_isShowing) return;

    _isShowing = true;
    _overlayEntry = OverlayEntry(
      builder: (context) => LoadingWidget(message: message),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  /// 隐藏Loading
  static void hide() {
    if (!_isShowing) return;

    _overlayEntry?.remove();
    _overlayEntry = null;
    _isShowing = false;
  }

  /// 检查是否正在显示
  static bool get isShowing => _isShowing;
}

/// Loading组件
class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
              message != null
                  ? Column(
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          message!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}

/// 带Loading的Mixin
mixin LoadingMixin<T extends StatefulWidget> on State<T> {
  /// 显示Loading
  void showLoading({String? message}) {
    LoadingUtil.show(context, message: message);
  }

  /// 隐藏Loading
  void hideLoading() {
    LoadingUtil.hide();
  }

  /// 执行带Loading的异步操作
  Future<R> withLoading<R>(
    Future<R> Function() operation, {
    String? loadingMessage,
  }) async {
    try {
      showLoading(message: loadingMessage);
      final result = await operation();
      return result;
    } finally {
      hideLoading();
    }
  }
}
