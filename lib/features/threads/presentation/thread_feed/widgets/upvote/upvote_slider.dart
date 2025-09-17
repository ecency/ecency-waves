import 'package:flutter/material.dart';

class UpvoteSlider extends StatefulWidget {
  const UpvoteSlider({
    super.key,
    required this.onChanged,
    required this.initialWeight,
  });

  final Function(double) onChanged;
  final double initialWeight;

  @override
  State<UpvoteSlider> createState() => _UpvoteSliderState();
}

class _UpvoteSliderState extends State<UpvoteSlider> {
  late double sliderValue;

  @override
  void initState() {
    sliderValue = widget.initialWeight;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant UpvoteSlider oldWidget) {
    sliderValue = widget.initialWeight;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Slider(
          value: sliderValue,
          min: 0.01,
          inactiveColor: theme.colorScheme.tertiary,
          label: '${(sliderValue * 100).round()} %',
          onChanged: (value) {
            widget.onChanged(value);
            setState(
              () {
                sliderValue = value;
              },
            );
          },
        ),
        Text(
          displayWeight(),
          textAlign: TextAlign.center,
          style:
              theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String displayWeight() {
    var voteValue = sliderValue * 100;
    var intVoteValue = voteValue.round();
    return "$intVoteValue %";
  }
}
