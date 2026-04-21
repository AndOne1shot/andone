import 'package:flutter/material.dart';

const kScreenBorder = Color(0xFF6B8C3A);
const kDark = Color(0xFF2D4A0E);
const kLight = Color(0xFFC8E898);
const kMid = Color(0xFF4A6A1A);

class PixelField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final IconData icon;

  const PixelField({
    super.key,
    required this.label,
    required this.controller,
    required this.obscure,
    required this.icon,
  });

  @override
  State<PixelField> createState() => _PixelFieldState();
}

class _PixelFieldState extends State<PixelField> {
  late bool _isObscure;

  @override
  void initState() {
    super.initState();
    _isObscure = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: kDark,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: widget.controller,
          obscureText: _isObscure,
          style: const TextStyle(
            fontSize: 16,
            color: kDark,
            letterSpacing: 1,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: kLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: kDark, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: kDark, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: kDark, width: 2.5),
            ),
            prefixIcon: Icon(widget.icon, color: kMid, size: 20),
            suffixIcon: widget.obscure
                ? IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility_off : Icons.visibility,
                      color: kMid,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 18,
            ),
          ),
        ),
      ],
    );
  }
}
