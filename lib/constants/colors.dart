import 'package:flutter/material.dart';

const primaryColor = Color(0xFF1A8E74);
const Color offWhiteColor = Color(0xFFF5F5F5);

/// A list of predefined gradients to be used for the avatar backgrounds.
final List<LinearGradient> _categoryGradients = [
  const LinearGradient(
      colors: [Color(0xff64B5F6), Color(0xff1976D2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
  const LinearGradient(
      colors: [Color(0xff81C784), Color(0xff388E3C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
  const LinearGradient(
      colors: [Color(0xffE57373), Color(0xffD32F2F)], begin: Alignment.topLeft, end: Alignment.bottomRight),
  const LinearGradient(
      colors: [Color(0xffFFB74D), Color(0xffF57C00)], begin: Alignment.topLeft, end: Alignment.bottomRight),
  const LinearGradient(
      colors: [Color(0xffBA68C8), Color(0xff7B1FA2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
  const LinearGradient(
      colors: [Color(0xff4DB6AC), Color(0xff00796B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
  const LinearGradient(
      colors: [Color(0xffF06292), Color(0xffC2185B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
  const LinearGradient(
      colors: [Color(0xffFFD54F), Color(0xffFFA000)], begin: Alignment.topLeft, end: Alignment.bottomRight),
];

/// Returns a LinearGradient based on the first character of the input string.
LinearGradient getGradientForCategory(String category) {
  if (category.isEmpty) {
    // Return a default gradient if the category is empty
    return _categoryGradients[0];
  }
  // Use the character code of the first letter to select a gradient
  final int index = category.toUpperCase().codeUnitAt(0) % _categoryGradients.length;
  return _categoryGradients[index];
}
