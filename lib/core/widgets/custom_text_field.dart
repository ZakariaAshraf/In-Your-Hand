import 'package:flutter/material.dart';
import 'package:in_your_hand/core/utils/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? suffixText;
  final String? title;
  final int? maxLines;
  final double? borderRadius;
  final IconData? suffixIcon;
  final IconData? prefixIcon;
  final void Function(String)? onChanged;
  final bool isPassword;

  const CustomTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.suffixText,
    this.onChanged,
    this.isPassword = false,
    this.title,
    this.suffixIcon,
    this.prefixIcon,
    this.maxLines =1,
    this.borderRadius,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ?widget.title != null
              ? Text(widget.title!, style: theme.titleSmall)
              : null,
          SizedBox(height: 4,),
          TextFormField(
            maxLines: widget.maxLines ?? null,
            style: theme.bodyLarge,
            onChanged: widget.onChanged,
            controller: widget.controller,
            obscureText: _obscure,
            decoration: InputDecoration(
              filled: true,
              hintText: widget.hintText,
              hintStyle: theme.titleMedium!.copyWith(color: Colors.grey),
              suffixText: widget.suffixText,
              floatingLabelBehavior: FloatingLabelBehavior.never,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
                borderSide: BorderSide(color: Colors.black.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
                borderSide: BorderSide(color: AppColors.primary),
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(widget.prefixIcon)
                  : null,
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscure = !_obscure;
                        });
                      },
                    )
                  : Icon(widget.suffixIcon),
            ),
            validator: (val) =>
                val == null || val.isEmpty ? 'Please fill this' : null,
          ),
        ],
      ),
    );
  }
}
