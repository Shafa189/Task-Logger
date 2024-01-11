import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SearchInput extends StatelessWidget {
  const SearchInput({
    Key? key,
    required this.controller,
    required this.hint,
    required this.onChanged,
    required FocusNode focusNode,
  }) : super(key: key);

  final TextEditingController controller;
  final String hint;
  final Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextFormField(
        onChanged: onChanged,
        controller: controller,
        style: TextStyle(color: Colors.white),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: hint,
          isDense: true,
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(36),
            borderSide: BorderSide(color: Colors.white, width: 2.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(36),
            borderSide: BorderSide(color: Colors.white, width: 2.0),
          ),
          hintStyle: TextStyle(color: Colors.white),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(6),
            child: SvgPicture.asset(
              'assets/search.svg',
              color: Colors.white,
            ),
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }
}
