import 'package:flutter/material.dart';

class ViewImage extends StatefulWidget {
  const ViewImage({
    super.key,
    required this.images,
    required this.image,
  });

  final List<String> images;
  final String image;

  @override
  State<ViewImage> createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage>
    with SingleTickerProviderStateMixin {
  late final TransformationController controller;
  late final AnimationController animationController;
  late final PageController pageController;
  Animation<Matrix4>? animation;
  int currentIndex = 0;

  final double minScale = 1;
  final double maxScale = 4;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: initialIndex);
    controller = TransformationController();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() {
        controller.value = animation!.value;
      });
  }

  @override
  void dispose() {
    controller.dispose();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        alignment: AlignmentDirectional.center,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              color: Colors.transparent,
            ),
          ),
          Positioned(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Hero(
                tag: widget.image,
                child: Center(
                  child: InteractiveViewer(
                    transformationController: controller,
                    panEnabled: false,
                    clipBehavior: Clip.none,
                    minScale: minScale,
                    maxScale: maxScale,
                    onInteractionEnd: (details) {
                      resetAnimation();
                    },
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: widget.images.length,
                      onPageChanged: (value) {
                        if (mounted) {
                          setState(() {
                            currentIndex = value;
                          });
                        }
                      },
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Image.network(widget.images[index]),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: theme.primaryColorLight.withOpacity(0.5),
              centerTitle: true,
              leading: const SizedBox.shrink(),
              title: Text(
                '${currentIndex + 1}/${widget.images.length}',
                style: theme.textTheme.displaySmall,
              ),
              actions: [
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close))
              ],
            ),
          )
        ],
      ),
    );
  }

  void resetAnimation() {
    animation = Matrix4Tween(
      begin: controller.value,
      end: Matrix4.identity(),
    ).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeIn));
    animationController.forward(from: 0);
  }

  int get initialIndex {
    int index = widget.images.indexWhere((element) => element == widget.image);
    return index != -1 ? index : 0;
  }
}
