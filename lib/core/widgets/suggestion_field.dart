import 'package:flutter/material.dart';
import 'package:riverpod_project/core/theme/app_theme.dart';
import 'package:riverpod_project/core/widgets/custom_text.dart';

/// A responsive TextField that shows a live dropdown of filtered suggestions
/// below the input. Works for any page — just pass a [suggestions] list.
class SuggestionField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final List<String> suggestions;
  final bool obscureText;
  final Widget? suffixWidget;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSelected;

  /// Light-theme variant (home search, cart promo, etc.)
  final bool darkMode;

  const SuggestionField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.suggestions,
    this.obscureText = false,
    this.suffixWidget,
    this.keyboardType,
    this.focusNode,
    this.validator,
    this.onChanged,
    this.onSelected,
    this.darkMode = false,
  });

  @override
  State<SuggestionField> createState() => _SuggestionFieldState();
}

class _SuggestionFieldState extends State<SuggestionField>
    with SingleTickerProviderStateMixin {
  late final FocusNode _focusNode;
  List<String> _filtered = [];
  bool _showDropdown = false;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;

  Color get _bg => widget.darkMode ? AppTheme.darkCard : Colors.white;
  Color get _border =>
      widget.darkMode ? AppTheme.darkBorder : const Color(0xFFBBF7D0);
  Color get _focusBorder =>
      widget.darkMode ? AppTheme.primaryColor : AppTheme.primaryGreen;
  Color get _text => widget.darkMode ? AppTheme.textPrimary : AppTheme.textDark;
  Color get _hint =>
      widget.darkMode ? AppTheme.textSecondary : AppTheme.textGrey;
  Color get _iconColor =>
      widget.darkMode ? AppTheme.textSecondary : AppTheme.primaryGreen;
  Color get _dropBg => widget.darkMode ? AppTheme.darkCard : Colors.white;
  Color get _dropText => widget.darkMode
      ? const Color.fromARGB(255, 15, 15, 15)
      : AppTheme.textDark;
  Color get _dropHover => widget.darkMode
      ? AppTheme.darkSurface
      : const Color.fromARGB(255, 12, 12, 12);

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<double>(begin: -8, end: 0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
    );

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _hide();
      }
    });

    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final query = widget.controller.text.trim().toLowerCase();
    if (query.isEmpty) {
      _hide();
      return;
    }
    final results = widget.suggestions
        .where((s) => s.toLowerCase().contains(query))
        .take(6)
        .toList();

    setState(() {
      _filtered = results;
      _showDropdown = results.isNotEmpty;
    });
    if (_showDropdown) {
      _animCtrl.forward();
    }
  }

  void _hide() {
    _animCtrl.reverse().then((_) {
      if (mounted) setState(() => _showDropdown = false);
    });
  }

  void _select(String value) {
    widget.controller.text = value;
    widget.controller.selection = TextSelection.collapsed(offset: value.length);
    widget.onSelected?.call(value);
    widget.onChanged?.call(value);
    _focusNode.unfocus();
    _hide();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Text field ──────────────────────────────────────────────────────
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onChanged: widget.onChanged,
          style: TextStyle(
            color: _text,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            labelStyle: TextStyle(color: _hint, fontSize: 13),
            hintStyle: TextStyle(color: _hint, fontSize: 13),
            prefixIcon: Icon(widget.icon, color: _iconColor, size: 20),
            suffixIcon: widget.suffixWidget,
            filled: true,
            fillColor: _bg,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: _border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: _border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: _focusBorder, width: 1.8),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: Color.fromARGB(255, 13, 13, 13)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                  color: Color.fromARGB(255, 6, 6, 6), width: 1.8),
            ),
          ),
        ),

        // ── Suggestions dropdown ─────────────────────────────────────────────
        if (_showDropdown)
          AnimatedBuilder(
            animation: _animCtrl,
            builder: (context, child) => Opacity(
              opacity: _fadeAnim.value,
              child: Transform.translate(
                offset: Offset(0, _slideAnim.value),
                child: child,
              ),
            ),
            child: Container(
              margin: const EdgeInsets.only(top: 4),
              constraints: const BoxConstraints(maxHeight: 240),
              decoration: BoxDecoration(
                color: _dropBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _focusBorder.withOpacity(0.25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: _focusBorder.withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: _focusBorder.withOpacity(0.1),
                  ),
                  itemBuilder: (context, i) {
                    final item = _filtered[i];
                    final query = widget.controller.text.trim().toLowerCase();
                    final matchStart = item.toLowerCase().indexOf(query);
                    final matchEnd = matchStart + query.length;

                    return _SuggestionTile(
                      text: item,
                      matchStart: matchStart,
                      matchEnd: matchEnd,
                      normalColor: _dropText,
                      highlightColor: _focusBorder,
                      hoverColor: _dropHover,
                      icon: widget.icon,
                      iconColor: _iconColor,
                      onTap: () => _select(item),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Individual suggestion tile ───────────────────────────────────────────────
class _SuggestionTile extends StatefulWidget {
  final String text;
  final int matchStart;
  final int matchEnd;
  final Color normalColor;
  final Color highlightColor;
  final Color hoverColor;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _SuggestionTile({
    required this.text,
    required this.matchStart,
    required this.matchEnd,
    required this.normalColor,
    required this.highlightColor,
    required this.hoverColor,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  State<_SuggestionTile> createState() => _SuggestionTileState();
}

class _SuggestionTileState extends State<_SuggestionTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          color: _hovered ? widget.hoverColor : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            children: [
              Icon(widget.icon, color: widget.iconColor, size: 16),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHighlightedText(),
              ),
              Icon(
                Icons.north_west_rounded,
                color: widget.iconColor.withOpacity(0.5),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightedText() {
    if (widget.matchStart < 0 ||
        widget.matchEnd > widget.text.length ||
        widget.matchStart >= widget.matchEnd) {
      return CustomText(
        widget.text,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          color: widget.normalColor,
          fontWeight: FontWeight.w400,
        ),
      );
    }
    return RichText(
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          if (widget.matchStart > 0)
            TextSpan(
              text: widget.text.substring(0, widget.matchStart),
              style: TextStyle(
                fontSize: 13,
                color: widget.normalColor,
                fontWeight: FontWeight.w400,
              ),
            ),
          TextSpan(
            text: widget.text.substring(widget.matchStart, widget.matchEnd),
            style: TextStyle(
              fontSize: 13,
              color: widget.highlightColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (widget.matchEnd < widget.text.length)
            TextSpan(
              text: widget.text.substring(widget.matchEnd),
              style: TextStyle(
                fontSize: 13,
                color: widget.normalColor,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
    );
  }
}
