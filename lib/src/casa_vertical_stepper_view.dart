import 'package:casa_vertical_stepper/src/model/stepper_steps.dart';
import 'package:flutter/material.dart';

part "../src/utils/consts.dart";

late Color completeColor;
late Color inProgressColor;
late Color upComingColor;

class CasaVerticalStepperView extends StatefulWidget {
  final List<StepperStep> steps;

  final Color? backgroundColor;

  /// this color will apply single color to all seperator line
  /// if this value is null then apply color according to [completeColor], [inProgressColor], [upComingColor]
  final Color? seperatorColor;
  final bool isExpandable;
  final bool showStepStatusWidget;
  final ScrollPhysics? physics;

  const CasaVerticalStepperView({
    required this.steps,
    this.seperatorColor,
    this.backgroundColor,
    this.isExpandable = false,
    this.showStepStatusWidget = true,
    this.physics,
    Key? key,
  }) : super(key: key);

  @override
  State<CasaVerticalStepperView> createState() =>
      _CasaVerticalStepperViewState();
}

class _CasaVerticalStepperViewState extends State<CasaVerticalStepperView> {
  late List<StepperStep> steps = [];
  late List<GlobalKey> _keys;

  @override
  void initState() {
    rebuild();
    _keys = List<GlobalKey>.generate(widget.steps.length, (_) => GlobalKey());
    super.initState();
  }

  void rebuild() {
    steps.clear();
    for (var step in widget.steps) {
      if (step.visible) steps.add(step);
    }
  }

  void expansionCallback(int index, bool isExpanded){
    setState(() => widget.steps[index].isExpanded = !isExpanded);
    if (isExpanded) rebuild();
  }

  @override
  Widget build(BuildContext context) {
    return widget.isExpandable && steps.isNotEmpty
        ? ExpansionPanelList(
            elevation: _kElevation,
            // dividerColor: Colors.black,
            expandedHeaderPadding: EdgeInsets.zero,
            expansionCallback: expansionCallback,
            children: steps.map<ExpansionPanel>((StepperStep step) {
              return ExpansionPanel(
                backgroundColor: widget.backgroundColor ??
                    Theme.of(context).scaffoldBackgroundColor,
                canTapOnHeader: true,
                headerBuilder: (_, __) => BuildVerticalHeader(step: step),
                body: BuildVerticalBody(
                  step: step,
                  separatorColor: widget.seperatorColor,
                ),
                isExpanded: step.isExpanded,
              );
            }).toList(),
          )
        : ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: widget.physics ?? const NeverScrollableScrollPhysics(),
            children: steps
                .map(
                  (step) => Visibility(
                    visible: step.visible,
                    child: Column(
                      key: _keys[steps.indexOf(step)],
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        BuildVerticalHeader(step: step),
                        BuildVerticalBody(
                          step: step,
                          separatorColor: widget.seperatorColor,
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          );
  }
}

class BuildVerticalBody extends StatelessWidget {
  final StepperStep step;
  final Color? separatorColor;

  const BuildVerticalBody({
    Key? key,
    required this.step,
    this.separatorColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        PositionedDirectional(
          start: _kStepMargin,
          // top: kTopMargin,
          // bottom: _kStepMargin,
          top: 8,
          bottom: 8,
          child: SizedBox(
            width: _kStepSize,
            child: Center(
              child: SizedBox(
                width: _kLineWidth,
                child: Container(
                  color: separatorColor ?? _stepColor(step.status),
                ),
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsetsDirectional.only(
            start: 1.5 * _kStepMargin + _kStepSize,
            end: _kStepMargin,
            bottom: _kStepMargin,
            top: _kTopMargin,
          ),
          child: step.status == StepStatus.fail ? step.failedView : step.view,
        ),
      ],
    );
  }
}

class BuildVerticalHeader extends StatelessWidget {
  final StepperStep step;

  const BuildVerticalHeader({Key? key, required this.step}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: _kStepMargin),
      child: Row(
        children: <Widget>[
          BuildIcon(status: step.status, leading: step.leading),
          Flexible(
            child: Container(
              margin: const EdgeInsetsDirectional.only(start: _kStepSpacing),
              child: step.title,
            ),
          ),
          step.trailing ?? const SizedBox(height: 0, width: 0)
        ],
      ),
    );
  }
}

class BuildIcon extends StatelessWidget {
  final StepStatus? status;
  final Widget? leading;

  const BuildIcon({
    Key? key,
    this.status,
    this.leading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (leading != null) {
      return leading!;
    } else {
      switch (status) {
        case StepStatus.complete:
          return Icon(Icons.check_box, color: completeColor, size: _kIconSize);
        case StepStatus.inprogress:
          return Icon(Icons.check_box_outlined,
              color: inProgressColor, size: _kIconSize);
        case StepStatus.upcoming:
          return Icon(Icons.check_box_outlined,
              color: upComingColor, size: _kIconSize);
        case StepStatus.fail:
          return Icon(Icons.warning,
              color: _defaultFailColor, size: _kIconSize);
        default:
          return Icon(Icons.check_box_outlined,
              color: inProgressColor, size: _kIconSize);
      }
    }
  }
}

Color _stepColor(StepStatus status) {
  switch (status) {
    case StepStatus.complete:
      return completeColor;
    case StepStatus.inprogress:
      return inProgressColor;
    case StepStatus.upcoming:
      return upComingColor;
    default:
      return _defaultFailColor;
  }
}
