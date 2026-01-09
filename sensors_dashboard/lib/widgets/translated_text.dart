import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../services/translation_service.dart';
class TranslatedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow overflow;
  final bool softWrap;
  final Widget? loadingWidget;
  final double? width;
  final bool useShimmerEffect;
  const TranslatedText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.softWrap = true,
    this.loadingWidget,
    this.width,
    this.useShimmerEffect = true,
  });
    @override
  Widget build(BuildContext context) {
    final translationService = Provider.of<TranslationService>(context);
    return FutureBuilder<String>(
      future: translationService.translateText(text),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && 
            !snapshot.hasData && loadingWidget != null) {
          return loadingWidget!;
        }
        final translatedText = snapshot.data ?? text;
        final isLoading = snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData;
        final textWidget = Text(
          translatedText,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          softWrap: softWrap,
        );
        if (isLoading && useShimmerEffect) {
          return width != null ? SizedBox(
            width: width,
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: textWidget,
            ),
          ) : Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: textWidget,
          );
        }
        return width != null ? SizedBox(
          width: width,
          child: textWidget,
        ) : textWidget;
      },
    );
  }
}
class TranslatedTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final TextStyle? style;
  const TranslatedTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style,
  });
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: Provider.of<TranslationService>(context).translateText(text),
      builder: (context, snapshot) {
        return TextButton(
          onPressed: onPressed,
          child: Text(
            snapshot.data ?? text,
            style: style,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }
}
class TranslatedElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final bool isLoading;
  const TranslatedElevatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style,
    this.isLoading = false,
  });
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: Provider.of<TranslationService>(context).translateText(text),
      builder: (context, snapshot) {
        final content = isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                snapshot.data ?? text,
                style: const TextStyle(),
                overflow: TextOverflow.ellipsis,
              );
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: style,
          child: content,
        );
      },
    );
  }
}
