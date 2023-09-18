//
// Copyright 2021-2022 present Insolite. All rights reserved.
// Use of this source code is governed by Apache 2.0 license
// that can be found in the LICENSE file.
//

library field_suggestion;

import 'dart:async';

import 'package:field_suggestion/search_state_manager.dart';

import 'utils.dart';
import 'styles.dart';
import 'box_controller.dart';
import 'package:flutter/material.dart';

export 'package:field_suggestion/styles.dart';
export 'package:field_suggestion/box_controller.dart';
export 'package:highlightable/highlightable.dart';

/// Create highly customizable, simple, and controllable autocomplete fields.
///
/// Basic usage example:
/// ```dart
/// FieldSuggestion(
///    textController: _textController,
///    suggestions: suggestions,
///    search: (item, input) {
///       return item.toString().contains(input);
///    },
///    itemBuilder: (context, index) {
///       return Card(...);
///    },
///    ...
/// )
/// ```
///
/// ---
///
/// Network usage example:
/// ```dart
/// FieldSuggestion<String>.network(
///   future: future,
///   textController: textController,
///   builder: (context, snapshot) {
///     if (snapshot.connectionState != ConnectionState.done) {
///       return Center(child: CircularProgressIndicator());
///     }
///
///     final result = snapshot.data ?? [];
///     return ListView.builder(
///       itemCount: result.length,
///       itemBuilder: (context, index) {
///         return GestureDetector(
///           onTap: () {
///             // ... Do something ...
///           },
///           child: ListTile(title: Text(result[index])),
///         );
///       },
///     );
///   },
/// )
/// ```
///
/// ---
///
/// ### Widget Structure of [FieldSuggestion].
///  ╭───────╮      ╭─────────────╮
///  │ Input │╮    ╭│ Suggestions │
///  ╰───────╯│    │╰─────────────╯
///           │    │
///           │    │               Generated by
///           │  Element         search algorithm
///           │    │              ╭──────────╮
///           ▼    ▼          ╭──▶│ Matchers │─╮
///     ╭──────────────────╮  │   ╰──────────╯ │  ╭──────────────╮
///     │ Search Algorithm │──╯                ╰─▶│ Item Builder │
///     ╰──────────────────╯                      ╰──────────────╯
///      Passes input and suggestion's             ... Passes context and
///      element to search function.               index of "matcher in suggestions".
///      So, as a result matchers                  suggestion item widget.
///      fill be filled appropriate
///      to algorithm
///
/// ---
///
/// ### Widget Structure of [FieldSuggestion.network].
///  ╭───────╮
///  │ Input │╮
///  ╰───────╯│          ╭──────────╮
///           ▼      ╭──▶│ snapshot │─╮
///       ╭────────╮ │   ╰──────────╯ │  ╭─────────╮
///       │ future │─╯                ╰─▶│ builder │
///       ╰────────╯                     ╰─────────╯
///
/// For mode details about usage refer to:
///  > https://github.com/theiskaa/field_suggestion/wiki
class FieldSuggestion<T> extends StatefulWidget {
  const FieldSuggestion({
    Key? key,
    required this.itemBuilder,
    required this.textController,
    required this.suggestions,
    required this.search,
    this.separatorBuilder,
    this.boxController,
    this.boxStyle,
    this.maxBoxHeight,
    this.inputDecoration,
    this.inputType,
    this.focusNode,
    this.maxLines,
    this.inputStyle,
    this.validator,
    this.cursorWidth = 2,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorColor,
    this.keyboardAppearance,
    this.scrollController,
    this.spacer = 5.0,
    this.sizeByItem,
    this.padding = const EdgeInsets.all(12),
    this.wOpacityAnimation = false,
    this.wSlideAnimation = false,
    this.animationDuration = const Duration(milliseconds: 400),
    this.slideStyle = SlideStyle.RTL,
    this.slideOffset,
    this.slideCurve = Curves.decelerate,
  })  : future = null,
        builder = null,
        targetWidget = null,
        futureRebuildDuration = null,
        initialData = null,
        onData = null,
        onError = null,
        onLoad = null,
        onEmptyData = null,
        assert(
          itemBuilder != null,
          '[itemBuilder] property cannot be null, in case of "local" usage',
        ),
        assert(
          suggestions != null,
          '[suggestions] property cannot be null, in case of "local" usage',
        ),
        assert(
          search != null,
          '[search] propery cannot be null, in case of "local" usage',
        ),
        super(key: key);

  const FieldSuggestion.network({
    Key? key,
    required this.textController,
    required this.future,
    required this.builder,
    this.targetWidget,
    this.initialData,
    this.futureRebuildDuration,
    this.onData,
    this.onError,
    this.onLoad,
    this.onEmptyData,
    this.boxController,
    this.boxStyle,
    this.maxBoxHeight,
    this.inputDecoration,
    this.inputType,
    this.focusNode,
    this.maxLines,
    this.inputStyle,
    this.validator,
    this.cursorWidth = 2,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorColor,
    this.keyboardAppearance,
    this.scrollController,
    this.spacer = 5.0,
    this.sizeByItem,
    this.padding = const EdgeInsets.all(12),
    this.wOpacityAnimation = false,
    this.wSlideAnimation = false,
    this.animationDuration = const Duration(milliseconds: 400),
    this.slideStyle = SlideStyle.RTL,
    this.slideOffset,
    this.slideCurve = Curves.decelerate,
  })  : itemBuilder = null,
        separatorBuilder = null,
        search = null,
        suggestions = null,
        assert(
          future != null,
          '[future] propery cannot be null, in case of "network" usage',
        ),
        assert(
          builder != null,
          '[builder] propery cannot be null, in case of "network" usage',
        ),
        super(key: key);

  /// Main text editing controller.
  ///
  /// Widget listens controller and calls appropriate functionalities
  /// to execute search algorithm and fill matchers.
  final TextEditingController textController;

  /// A list of suggested items to be displayed by the widget.
  ///
  /// This is a list of items that have been passed in early, and is required for
  /// local usage of the suggestions field. As shown in the simple structure diagram,
  /// the widget will search for input in the passed list of suggestions.
  final List<T>? suggestions;

  /// The search algorithm used by the widget.
  ///
  /// This function is used for local usage of the Field Suggestion widget and is called
  /// for each item in the `suggestions` list with the current input as arguments.
  ///
  /// The function should return a boolean indicating whether the given item matches
  /// the current input. For example:
  ///
  /// ```dart
  /// // Example search function that checks if an item contains the input string.
  /// search: (item, input) => item.toString().contains(input)
  /// ```
  final bool Function(T item, String input)? search;

  /// The asynchronous computation that this builder is currently connected to, which may be null.
  ///
  /// If no future has completed yet, including in the case where [future] is null,
  /// the [builder] function will use [initialData] to provide initial data.
  ///
  /// This property can be thought of as the asynchronous version of [suggestions].
  final Future<List<T>> Function(String input)? future;

  /// The builder function that creates suggestion widgets for the FieldSuggestion widget.
  ///
  /// This function takes in a [BuildContext] and an index and returns a widget
  /// that will be displayed as a suggestion. The index corresponds to the position
  /// of the suggestion in the `suggestions` list.
  ///
  /// Example usage:
  ///
  /// ```dart
  /// FieldSuggestion(
  ///   itemBuilder: (context, index) {
  ///     return Card(
  ///       // Customize the suggestion widget as needed.
  ///     );
  ///   }
  ///   ...
  /// )
  /// ```
  final Widget Function(BuildContext, int)? itemBuilder;

  /// The builder function that creates separators for the suggestion list.
  ///
  /// This function takes a [BuildContext] and an index as arguments, and returns a
  /// separator widget that will be displayed between each suggestion widget. The index
  /// corresponds to the position of the suggestion in the `suggestions` list.
  ///
  /// This property is similar to the `ListView.seperated` but as property.
  ///
  /// Example usage:
  ///
  /// ```dart
  /// FieldSuggestion(
  ///   separatorBuilder: (context, index) {
  ///     return const Divider();
  ///   },
  ///   ...
  /// )
  /// ```
  final Widget Function(BuildContext, int)? separatorBuilder;

  /// The build strategy currently used by this builder.
  ///
  /// The builder is provided with an [AsyncSnapshot] object whose
  /// [AsyncSnapshot.connectionState] property will be one of the following
  /// values:
  ///
  ///  * [ConnectionState.none]: [future] is null. The [AsyncSnapshot.data] will
  ///    be set to [initialData], unless a future has previously completed, in
  ///    which case the previous result persists.
  ///
  ///  * [ConnectionState.waiting]: [future] is not null, but has not yet
  ///    completed. The [AsyncSnapshot.data] will be set to [initialData],
  ///    unless a future has previously completed, in which case the previous
  ///    result persists.
  ///
  ///  * [ConnectionState.done]: [future] is not null, and has completed. If the
  ///    future completed successfully, the [AsyncSnapshot.data] will be set to
  ///    the value to which the future completed. If it completed with an error,
  ///    [AsyncSnapshot.hasError] will be true and [AsyncSnapshot.error] will be
  ///    set to the error object.
  ///
  /// This builder must only return a widget and should not have any side
  /// effects as it may be called multiple times.
  ///
  /// For more: check [FutureBuilder]'s [builder] property.
  final Widget Function(BuildContext, AsyncSnapshot<List<T>>)? builder;

  /// CompositedTransformTarget Widget.
  final Widget? targetWidget;

  /// The rebuild delay for the [future] computation.
  ///
  /// If unset, the delay will be instant, meaning that [future] will be
  /// re-run immediately upon any change to the [textController].
  ///
  /// You can set a rebuild delay to avoid excessive calls to [future] while
  /// the user is typing. For example, if you set a delay of 500 milliseconds,
  /// [future] will only be re-run 500 milliseconds after the user stops typing.
  final Duration? futureRebuildDuration;

  /// The data that will be used to create the snapshots provided until a
  /// non-null [future] has completed.
  ///
  /// If the future completes with an error, the data in the [AsyncSnapshot]
  /// provided to the [builder] will become null, regardless of [initialData].
  /// (The error itself will be available in [AsyncSnapshot.error], and
  /// [AsyncSnapshot.hasError] will be true.)
  ///
  /// Fore more: check [FutureBuilder]'s [initialData] property.
  final List<T>? initialData;

  /// A callback that will be called when the [future] completes successfully
  /// with a non-empty result.
  ///
  /// This callback is triggered when the [AsyncSnapshot.connectionState] is
  /// [ConnectionState.done] and [AsyncSnapshot.data] is not null.
  final void Function(AsyncSnapshot<List<T>>)? onData;

  /// A callback that will be called when the [future] completes with an error.
  ///
  /// This callback is triggered when the [AsyncSnapshot.connectionState] is
  /// [ConnectionState.done] and [AsyncSnapshot.hasError] is true.
  final void Function(AsyncSnapshot<List<T>>)? onError;

  /// A callback that will be called when the [future] starts running.
  ///
  /// This callback is triggered when the [AsyncSnapshot.connectionState] is
  /// [ConnectionState.waiting].
  final void Function(AsyncSnapshot<List<T>>)? onLoad;

  /// A callback that will be called when the [future] completes successfully
  /// with an empty result.
  ///
  /// This callback is triggered when the [AsyncSnapshot.connectionState] is
  /// [ConnectionState.done] and [AsyncSnapshot.hasData] is false.
  final void Function(AsyncSnapshot<List<T>>)? onEmptyData;

  /// The controller object for the suggestion box. Can be used to control the
  /// suggestion box by opening, closing, and refreshing the content.
  ///
  /// Use this property to manage the suggestion box externally. For example, to
  /// close the suggestion box when the user taps outside the box.
  ///
  /// For example:
  /// ```dart
  /// class ExternalControlExample extends StatelessWidget {
  ///   final _boxController = BoxController();
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     return GestureDetector(
  ///       onTap: () => _boxController.close?.call(),
  ///       child: Scaffold(
  ///         body: Center(
  ///           child: FieldSuggestion(
  ///             boxController: _boxController,
  ///             ...
  ///           ),
  ///         ),
  ///       ),
  ///     );
  ///   }
  /// }
  /// ```
  final BoxController? boxController;

  /// The style configuration for the suggestion box.
  ///
  /// If not specified, the default style defined by [BoxStyle.defaultStyle]
  /// will be used.
  final BoxStyle? boxStyle;

  /// The maximum height for the suggestion box.
  ///
  /// If not specified, the default value of 60 will be used.
  final double? maxBoxHeight;

  /// Text input decoration of input field.
  final InputDecoration? inputDecoration;

  /// Text input type of input field.
  final TextInputType? inputType;

  /// Focus node of input field.
  final FocusNode? focusNode;

  /// Max lines of the input field.
  final int? maxLines;

  /// Text style of input field.
  final TextStyle? inputStyle;

  /// Field's input validator.
  final FormFieldValidator<String>? validator;

  /// The width(thickness) of field's cursor.
  final double cursorWidth;

  /// The height(length) of field's cursor.
  final double? cursorHeight;

  /// The border radius of field's cursor.
  final Radius? cursorRadius;

  /// The color of field's cursor.
  final Color? cursorColor;

  /// The appearance of the keyboard.
  /// Honored only IOS devices, 'cause Apple is awesome.
  ///
  /// If unset, defaults to the brightness of "Theme.primaryColorBrightness".
  final Brightness? keyboardAppearance;

  /// Scroll controller for the suggestions list.
  final ScrollController? scrollController;

  /// Spacer is the value of size between field and box.
  ///
  /// If unset, defaults to the ─▶ [5.0].
  final double spacer;

  /// Sets suggestion box's height by item count.
  ///
  /// If [sizeByItem] equals [1] ─▶ x * 1.0
  /// ...
  /// If [sizeByItem] equals [3] ─▶ x * 3.0
  final int? sizeByItem;

  /// Padding of suggestion box's sub widgets.
  final EdgeInsets padding;

  /// Boolean to disable/enable opacity animation of [SuggestionBox].
  ///
  /// If unset, defaults to the ─▶ [false].
  final bool wOpacityAnimation;

  /// Boolean to enable/disable slide animation of [SuggestionBox].
  ///
  /// If unset, defaults to the ─▶ [false].
  final bool wSlideAnimation;

  /// Duration of suggestion box animation.
  ///
  /// If unset, defaults to the ─▶ [400 milliseconds].
  final Duration animationDuration;

  /// Rotation slide to determine tween offset of slide animation.
  ///
  /// **Right to left [RTL], Left to right [LTR], Bottom to up [BTU], Up to down [UTD].**
  final SlideStyle slideStyle;

  /// Tween offset of slide animation.
  ///
  /// When you use [slideOffset], then [slideStyle] automatically would be disabled.
  final Tween<Offset>? slideOffset;

  /// Curve for box slide animation.
  ///
  /// If unset, defaults to the ─▶ [Curves.decelerate].
  final Curve slideCurve;

  @override
  _FieldSuggestionState createState() =>
      _FieldSuggestionState<T>(boxController);
}

class _FieldSuggestionState<T> extends State<FieldSuggestion<T>>
    with TickerProviderStateMixin {
  // Initialize BoxController closures.
  _FieldSuggestionState(BoxController? _boxController) {
    if (_boxController == null) return;

    _boxController.close = closeBox;
    _boxController.open = openBox;
    _boxController.refresh = refresh;
  }

  // Manages the search state of `network` constructor via its `search` method.
  late SearchStateManager<T> searchManager;

  // Matchers that generated by [search]ing `input` in [suggestions].
  // and [itemBuilder] will be called according to this array.
  List<T> matchers = [];

  // "CURRENT" active overlay ─▶ represents suggestion box.
  OverlayEntry? _overlayEntry;

  // The collection of active overlays.
  final List<dynamic> _overlaysList = [];

  // Widget has two main parts ─▶ Input Field and Suggestion Box.
  // the whole widget uses layer link to connect that two parts.
  // It's bridge between suggestion box and input field.
  final LayerLink _layerLink = LayerLink();

  // Suggestion box's active style.
  // As default it'd be setted to ─▶ [BoxStyle.defaultStyle].
  BoxStyle? boxStyle;

  late Animation<double> _opacity;
  late Animation<Offset>? _slide;
  late AnimationController _animationController;

  @override
  void dispose() {
    widget.textController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    searchManager = SearchStateManager<T>(
      onData: widget.onData ?? (_) => openBox(),
      onError: widget.onError ?? (_) => closeBox(),
      onLoad: widget.onLoad ?? (_) => openBox(),
      onEmptyData: widget.onEmptyData ?? (_) => closeBox(),
      future: widget.future,
      initialState: widget.initialData == null
          ? AsyncSnapshot<List<T>>.nothing()
          : AsyncSnapshot<List<T>>.withData(
              ConnectionState.none,
              widget.initialData as List<T>,
            ),
    );

    widget.textController.addListener(_textListener);
    widget.focusNode?.addListener(() {
      bool? hasFocus = widget.focusNode?.hasFocus;
      if (hasFocus != null && !hasFocus) {
        closeBox();
      }
    });

    if (widget.wOpacityAnimation || widget.wSlideAnimation) {
      _animationController = AnimationController(
        vsync: this,
        duration: widget.animationDuration,
      );

      if (widget.wOpacityAnimation) {
        _opacity = Tween<double>(
          begin: 0,
          end: 1,
        ).animate(_animationController);
      }

      // Set slide animations if it was enabled.
      if (widget.wSlideAnimation) {
        _slide = FieldAnimationStyle.setBoxAnimation(
          slideStyle: widget.slideStyle,
          animationController: _animationController,
          slideTweenOffset: widget.slideOffset,
          slideCurve: widget.slideCurve,
        );
      }
    }
  }

  // A `Future` function that listens to changes in the text input.
  // The function searches for `input` in `suggestions` using `searchManager` if `future` is not `null`.
  // If `input` is empty, the function closes the box.
  // If `matchers` is empty after searching, the function closes the box, otherwise it opens the box.
  Future<void> _textListener() async {
    final input = widget.textController.text;

    if (widget.future != null) return searchManager.search(input);

    // Should close box if input is empty.
    if (input.isEmpty) return closeBox();

    matchers = widget.suggestions!.where((i) {
      return widget.search?.call(i, input.toString()) ?? false;
    }).toList();

    return (matchers.isEmpty) ? closeBox() : openBox();
  }

  // A set-state wrapper to avoid [setState after dispose] error.
  void _mountedSetState(void Function() fn) {
    if (this.mounted) setState(fn);
  }

  // A external callback function used to refresh content-state of box.
  // Uses clojure set-state and [_textListener] method to update the state.
  void refresh() {
    _mountedSetState(() {});
    _textListener();
  }

  // Method of opening suggestion box.
  // Could be used externally.
  void openBox() {
    // Clear current overlay.
    if (_overlayEntry != null && _overlaysList.isNotEmpty) {
      _overlayEntry!.remove();
      _mountedSetState(() => _overlayEntry = null);
    }

    // Generate a new one.
    _generateOverlay(context);
    if (widget.wOpacityAnimation || widget.wSlideAnimation) {
      _animationController.forward();
    }
  }

  // Method of closing suggestion box.
  // Could be used externally.
  void closeBox() {
    if (!(_overlayEntry != null && _overlaysList.isNotEmpty)) return;

    _overlayEntry!.remove();
    if (widget.wOpacityAnimation || widget.wSlideAnimation) {
      _animationController.reverse();
    }

    _mountedSetState(() => _overlayEntry = null);
  }

  // Creates the suggestion box (overlay entry).
  // Appends it to the overlay state and state overlay management list.
  void _generateOverlay(BuildContext context) {
    final _state = Overlay.of(context);
    final _size = (context.findRenderObject() as RenderBox).size;

    // Re-append overlay entry.
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: _size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, _size.height + widget.spacer),
          child: _buildSuggestionBox(context),
        ),
      ),
    );

    // Append refreshing functionality of overlay to the animation controller
    // if one of the animation property was enabled.
    if (widget.wOpacityAnimation || widget.wSlideAnimation) {
      _animationController.addListener(() => _state.setState(() {}));
    }

    // Insert generated overlay entry to overlay state.
    _state.insert(_overlayEntry!);

    // Add the overlay entry to cleared list.
    _overlaysList.clear();
    _overlaysList.add(_overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    boxStyle = widget.boxStyle ?? BoxStyle.defaultStyle(context);

    // Layer linking adds normal widget's behaviour to overlay widget.
    // It follows [TextField] every time if targetWidget is null, and behaves as a normal non-hidable widget.
    // Otherwise, it will follows targetWidget.
    return CompositedTransformTarget(
      link: _layerLink,
      child: widget.targetWidget ?? TextFormField(
        keyboardType: widget.inputType,
        focusNode: widget.focusNode,
        controller: widget.textController,
        maxLines: widget.maxLines,
        decoration: widget.inputDecoration,
        style: widget.inputStyle,
        validator: widget.validator,
        cursorWidth: widget.cursorWidth,
        cursorHeight: widget.cursorHeight,
        cursorRadius: widget.cursorRadius,
        cursorColor: widget.cursorColor,
        keyboardAppearance: widget.keyboardAppearance,
      ),
    );
  }

  // Generates suggestion box widget for overlay entry.
  // Used in [_generateOverlay] method.
  Widget _buildSuggestionBox(BuildContext context) {
    final _box = Opacity(
      opacity: (widget.wOpacityAnimation) ? _opacity.value : 1,
      child: Container(
        padding: widget.padding,
        decoration: BoxDecoration(
          color: boxStyle?.backgroundColor,
          borderRadius: boxStyle?.borderRadius,
          boxShadow: widget.boxStyle?.boxShadow,
          border: widget.boxStyle?.border,
        ),
        child: ValueListenableBuilder(
            valueListenable: searchManager,
            builder: (context, SearchState<T> value, _) {
              final len = value.snapshot.data?.length ?? 1;
              final match =
                  widget.future != null ? (len > 1 ? len : 1) : matchers.length;

              return BoxSizer(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width,
                  maxHeight: Utils.maxBoxHeight(
                    sizeByItem: widget.sizeByItem,
                    maxBoxHeight: widget.maxBoxHeight,
                    matchers: match,
                  ),
                ),
                child: Builder(builder: (context) {
                  if (widget.future != null) {
                    return widget.builder!(context, value.snapshot);
                  }

                  return ListView.separated(
                    controller: widget.scrollController,
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: matchers.length,
                    separatorBuilder: widget.separatorBuilder ??
                        (_, __) => const SizedBox.shrink(),
                    itemBuilder: (context, index) {
                      // Get the index of matcher[i] in suggestions list.
                      final mindex =
                          widget.suggestions!.indexOf(matchers[index]);
                      return widget.itemBuilder!(context, mindex);
                    },
                  );
                }),
              );
            }),
      ),
    );

    return Material(
      color: boxStyle?.backgroundColor,
      borderRadius: boxStyle?.borderRadius,
      elevation: 0,
      child: !widget.wSlideAnimation
          ? _box
          : SlideTransition(position: _slide!, child: _box),
    );
  }
}
