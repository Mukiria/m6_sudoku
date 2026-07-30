import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.variant = AppButtonVariant.filled,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.iconPosition = IconPosition.start,
    this.width,
    this.height,
    this.borderRadius,
    this.padding,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final Widget? icon;
  final IconPosition iconPosition;
  final double? width;
  final double? height;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final extension = theme.extension<AppThemeExtension>()!;

    final effectiveOnPressed = (isDisabled || isLoading) ? null : onPressed;

    final buttonHeight = height ?? _getButtonHeight(size);
    final buttonPadding = padding ?? _getButtonPadding(size);
    final buttonBorderRadius = borderRadius ?? 12.0;
    final textStyle = _getTextStyle(theme, size);

    Widget buttonChild = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == AppButtonVariant.filled
                    ? colorScheme.onPrimary
                    : colorScheme.primary,
              ),
            ),
          )
        : _buildChildWithIcon(context, textStyle);

    switch (variant) {
      case AppButtonVariant.filled:
        return SizedBox(
          width: width,
          height: buttonHeight,
          child: FilledButton(
            onPressed: effectiveOnPressed,
            style: FilledButton.styleFrom(
              padding: buttonPadding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonBorderRadius),
              ),
              textStyle: textStyle,
              minimumSize: Size(width ?? 0, buttonHeight),
            ).copyWith(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return colorScheme.onSurface.withValues(alpha: 0.12);
                }
                return null;
              }),
            ),
            child: buttonChild,
          ),
        );
      case AppButtonVariant.outlined:
        return SizedBox(
          width: width,
          height: buttonHeight,
          child: OutlinedButton(
            onPressed: effectiveOnPressed,
            style: OutlinedButton.styleFrom(
              padding: buttonPadding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonBorderRadius),
              ),
              textStyle: textStyle,
              minimumSize: Size(width ?? 0, buttonHeight),
              side: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.5),
                  );
                }
                return BorderSide(color: colorScheme.primary, width: 1.5);
              }),
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return colorScheme.onSurface.withValues(alpha: 0.38);
                }
                return colorScheme.primary;
              }),
            ).copyWith(
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return colorScheme.onSurface.withValues(alpha: 0.38);
                }
                return colorScheme.primary;
              }),
            ),
            child: buttonChild,
          ),
        );
      case AppButtonVariant.text:
        return SizedBox(
          width: width,
          height: buttonHeight,
          child: TextButton(
            onPressed: effectiveOnPressed,
            style: TextButton.styleFrom(
              padding: buttonPadding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonBorderRadius),
              ),
              textStyle: textStyle,
              minimumSize: Size(width ?? 0, buttonHeight),
            ),
            child: buttonChild,
          ),
        );
      case AppButtonVariant.elevated:
        return SizedBox(
          width: width,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: effectiveOnPressed,
            style: ElevatedButton.styleFrom(
              padding: buttonPadding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonBorderRadius),
              ),
              textStyle: textStyle,
              minimumSize: Size(width ?? 0, buttonHeight),
            ),
            child: buttonChild,
          ),
        );
      case AppButtonVariant.tonal:
        return SizedBox(
          width: width,
          height: buttonHeight,
          child: FilledButton.tonal(
            onPressed: effectiveOnPressed,
            style: FilledButton.styleFrom(
              padding: buttonPadding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonBorderRadius),
              ),
              textStyle: textStyle,
              minimumSize: Size(width ?? 0, buttonHeight),
            ),
            child: buttonChild,
          ),
        );
    }
  }

  Widget _buildChildWithIcon(BuildContext context, TextStyle textStyle) {
    if (icon == null) return DefaultTextStyle(style: textStyle, child: child);

    final iconSize = _getIconSize(size);
    final spacing = 8.0;

    return DefaultTextStyle(
      style: textStyle,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (iconPosition == IconPosition.start) ...[
            IconTheme(data: IconThemeData(size: iconSize), child: icon!),
            SizedBox(width: spacing),
          ],
          Flexible(child: child),
          if (iconPosition == IconPosition.end) ...[
            SizedBox(width: spacing),
            IconTheme(data: IconThemeData(size: iconSize), child: icon!),
          ],
        ],
      ),
    );
  }

  double _getButtonHeight(AppButtonSize size) {
    switch (size) {
      case AppButtonSize.small:
        return 36;
      case AppButtonSize.medium:
        return 48;
      case AppButtonSize.large:
        return 56;
    }
  }

  EdgeInsetsGeometry _getButtonPadding(AppButtonSize size) {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  TextStyle _getTextStyle(ThemeData theme, AppButtonSize size) {
    switch (size) {
      case AppButtonSize.small:
        return theme.textTheme.labelSmall!
            .copyWith(fontWeight: FontWeight.w600);
      case AppButtonSize.medium:
        return theme.textTheme.labelLarge!
            .copyWith(fontWeight: FontWeight.w600);
      case AppButtonSize.large:
        return theme.textTheme.titleMedium!
            .copyWith(fontWeight: FontWeight.w600);
    }
  }

  double _getIconSize(AppButtonSize size) {
    switch (size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 20;
      case AppButtonSize.large:
        return 24;
    }
  }
}

enum AppButtonVariant {
  filled,
  outlined,
  text,
  elevated,
  tonal,
}

enum AppButtonSize {
  small,
  medium,
  large,
}

enum IconPosition {
  start,
  end,
}

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size = 48,
    this.iconSize = 24,
    this.isDisabled = false,
    this.tooltip,
    this.color,
    this.backgroundColor,
    this.borderRadius,
    this.splashRadius,
  });

  final VoidCallback? onPressed;
  final Widget icon;
  final double size;
  final double iconSize;
  final bool isDisabled;
  final String? tooltip;
  final Color? color;
  final Color? backgroundColor;
  final double? borderRadius;
  final double? splashRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveOnPressed = isDisabled ? null : onPressed;
    final effectiveColor = color ?? colorScheme.onSurface;
    final effectiveBackgroundColor = backgroundColor ?? Colors.transparent;
    final effectiveBorderRadius = borderRadius ?? 12.0;

    Widget button = IconButton(
      onPressed: effectiveOnPressed,
      icon: IconTheme(
        data: IconThemeData(size: iconSize, color: effectiveColor),
        child: icon,
      ),
      style: IconButton.styleFrom(
        backgroundColor: effectiveBackgroundColor,
        foregroundColor: effectiveColor,
        disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
        disabledBackgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
        ),
      ),
      tooltip: tooltip,
      splashRadius: splashRadius,
    );

    return SizedBox(
      width: size,
      height: size,
      child: Center(child: button),
    );
  }
}

class AppFloatingActionButton extends StatelessWidget {
  const AppFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 4,
    this.focusElevation = 6,
    this.hoverElevation = 8,
    this.highlightElevation = 10,
    this.shape,
    this.isExtended = false,
    this.extendedPadding,
    this.extendedTextStyle,
    this.extendedIcon,
    this.extendedLabel,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final double focusElevation;
  final double hoverElevation;
  final double highlightElevation;
  final ShapeBorder? shape;
  final bool isExtended;
  final EdgeInsetsGeometry? extendedPadding;
  final TextStyle? extendedTextStyle;
  final Widget? extendedIcon;
  final Widget? extendedLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isExtended) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: backgroundColor ?? colorScheme.primary,
        foregroundColor: foregroundColor ?? colorScheme.onPrimary,
        elevation: elevation,
        focusElevation: focusElevation,
        hoverElevation: hoverElevation,
        highlightElevation: highlightElevation,
        shape: shape ??
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
        extendedPadding: extendedPadding ??
            const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        extendedTextStyle: extendedTextStyle ??
            theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        icon: extendedIcon,
        label: extendedLabel ?? child,
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? colorScheme.primary,
      foregroundColor: foregroundColor ?? colorScheme.onPrimary,
      elevation: elevation,
      focusElevation: focusElevation,
      hoverElevation: hoverElevation,
      highlightElevation: highlightElevation,
      shape: shape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
      child: child,
    );
  }
}
