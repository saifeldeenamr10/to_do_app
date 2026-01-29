import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

abstract class GetHelper {
  static push(Widget Function() dest, {Transition? transition}) {
    Get.to(dest, transition: transition ?? Transition.rightToLeft);
  }

  static pushReplace(Widget Function() dest, {Transition? transition}) {
    Get.off(dest, transition: transition ?? Transition.rightToLeft);
  }

  static pushReplaceAll(Widget Function() dest, {Transition? transition}) {
    Get.offAll(dest, transition: transition ?? Transition.rightToLeft);
  }

  static pop() {
    Get.back();
  }
}
