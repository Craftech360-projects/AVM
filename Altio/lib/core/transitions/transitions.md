1. Fade-In

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var fadeInAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeIn),
      );

      return FadeTransition(
        opacity: fadeInAnimation,
        child: child,
      );
    },
  ),
);


2. Fade-Out

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var fadeOutAnimation = Tween(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOut),
      );

      return FadeTransition(
        opacity: fadeOutAnimation,
        child: child,
      );
    },
  ),
);


3. Zoom-In

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var zoomInAnimation = Tween(begin: 0.9, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeIn),
      );

      return ScaleTransition(
        scale: zoomInAnimation,
        child: child,
      );
    },
  ),
);


4. Zoom-out

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var zoomOutAnimation = Tween(begin: 1.0, end: 0.9).animate(
        CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOut),
      );

      return ScaleTransition(
        scale: zoomOutAnimation,
        child: child,
      );
    },
  ),
);


5. Slide-In from Left

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var slideInAnimation = Tween(begin: Offset(-1.0, 0.0), end: Offset.zero).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeIn),
      );

      return SlideTransition(
        position: slideInAnimation,
        child: child,
      );
    },
  ),
);


6. Slide-In from Right

Navigator.push(
  context,
  PageRouteBuilder(
    transitionDuration: Duration(milliseconds: 800), // Adjusted transition duration for smoother effect
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var slideInAnimation = Tween<Offset>(
        begin: Offset(1.0, 0.0), 
        end: Offset.zero
      ).animate(
        CurvedAnimation(
          parent: animation, 
          curve: Curves.easeOut, // 'easeOut' gives a smoother, slower transition at the end
        ),
      );

      return SlideTransition(
        position: slideInAnimation,
        child: child,
      );
    },
  ),
);



7. Slide-In from Bottom

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var slideInAnimation = Tween(begin: Offset(0.0, 1.0), end: Offset.zero).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeIn),
      );

      return SlideTransition(
        position: slideInAnimation,
        child: child,
      );
    },
  ),
);


8. Slide-Out to Left

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var slideOutAnimation = Tween(begin: Offset.zero, end: Offset(-1.0, 0.0)).animate(
        CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOut),
      );

      return SlideTransition(
        position: slideOutAnimation,
        child: child,
      );
    },
  ),
);


9. Slide-Out to Right

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var slideOutAnimation = Tween(begin: Offset.zero, end: Offset(1.0, 0.0)).animate(
        CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOut),
      );

      return SlideTransition(
        position: slideOutAnimation,
        child: child,
      );
    },
  ),
);


10. Rotate-In

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var rotateInAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeIn),
      );

      return RotationTransition(
        turns: rotateInAnimation,
        child: child,
      );
    },
  ),
);


11. Rotate-Out

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var rotateOutAnimation = Tween(begin: 0.0, end: -1.0).animate(
        CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOut),
      );

      return RotationTransition(
        turns: rotateOutAnimation,
        child: child,
      );
    },
  ),
);


12. Scale-In (Bounce)

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var scaleInAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.bounceIn),
      );

      return ScaleTransition(
        scale: scaleInAnimation,
        child: child,
      );
    },
  ),
);


13. Scale-Out (Bounce)

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var scaleOutAnimation = Tween(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: secondaryAnimation, curve: Curves.bounceOut),
      );

      return ScaleTransition(
        scale: scaleOutAnimation,
        child: child,
      );
    },
  ),
);


14. Flip-In (X-Axis)

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var flipInAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeIn),
      );

      return AnimatedBuilder(
        animation: flipInAnimation,
        builder: (context, child) {
          return Transform(
            transform: Matrix4.rotationX(flipInAnimation.value * 3.14),
            alignment: Alignment.center,
            child: child,
          );
        },
        child: child,
      );
    },
  ),
);


15. Flip-Out (X-Axis)

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var flipOutAnimation = Tween(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOut),
      );

      return AnimatedBuilder(
        animation: flipOutAnimation,
        builder: (context, child) {
          return Transform(
            transform: Matrix4.rotationX(flipOutAnimation.value * 3.14),
            alignment: Alignment.center,
            child: child,
          );
        },
        child: child,
      );
    },
  ),
);


16. Fade and Slide-In (Diagonal)

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var fadeInAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeIn),
      );

      var slideInAnimation = Tween(begin: Offset(1.0, 1.0), end: Offset.zero).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeIn),
      );

      return FadeTransition(
        opacity: fadeInAnimation,
        child: SlideTransition(
          position: slideInAnimation,
          child: child,
        ),
      );
    },
  ),
);


17. Fade and Scale-In

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var fadeInAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeIn),
      );

      var scaleInAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeIn),
      );

      return FadeTransition(
        opacity: fadeInAnimation,
        child: ScaleTransition(
          scale: scaleInAnimation,
          child: child,
        ),
      );
    },
  ),
);


18. Bounce-In (Vertical)

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var bounceInAnimation = Tween(begin: -1.0, end: 0.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.bounceIn),
      );

      return SlideTransition(
        position: bounceInAnimation,
        child: child,
      );
    },
  ),
);


19. Flash Effect (Flashing)

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var flashAnimation = Tween(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeIn),
      );

      return AnimatedBuilder(
        animation: flashAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: flashAnimation.value,
            child: child,
          );
        },
        child: child,
      );
    },
  ),
);


20. Wobble Effect

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var wobbleAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.elasticInOut),
      );

      return AnimatedBuilder(
        animation: wobbleAnimation,
        builder: (context, child) {
          return Transform(
            transform: Matrix4.rotationZ(wobbleAnimation.value * 0.1),
            alignment: Alignment.center,
            child: child,
          );
        },
        child: child,
      );
    },
  ),
);


21. Card Flip (Horizontal)

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var flipAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeInOut),
      );

      return AnimatedBuilder(
        animation: flipAnimation,
        builder: (context, child) {
          return Transform(
            transform: Matrix4.rotationY(flipAnimation.value * 3.14),
            alignment: Alignment.center,
            child: child,
          );
        },
        child: child,
      );
    },
  ),
);


22. Swing Effect

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var swingAnimation = Tween(begin: -0.1, end: 0.1).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeInOut),
      );

      return AnimatedBuilder(
        animation: swingAnimation,
        builder: (context, child) {
          return Transform(
            transform: Matrix4.rotationZ(swingAnimation.value),
            alignment: Alignment.center,
            child: child,
          );
        },
        child: child,
      );
    },
  ),
);


23. Elastic (In & Out)

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var elasticInAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.elasticInOut),
      );

      return ScaleTransition(
        scale: elasticInAnimation,
        child: child,
      );
    },
  ),
);


24. Tilt Effect

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var tiltAnimation = Tween(begin: -0.1, end: 0.1).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeInOut),
      );

      return AnimatedBuilder(
        animation: tiltAnimation,
        builder: (context, child) {
          return Transform(
            transform: Matrix4.rotationX(tiltAnimation.value),
            alignment: Alignment.center,
            child: child,
          );
        },
        child: child,
      );
    },
  ),
);


25. Perspective 3D Zoom-In

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var perspectiveAnimation = Tween(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeIn),
      );

      return AnimatedBuilder(
        animation: perspectiveAnimation,
        builder: (context, child) {
          return Transform(
            transform: Matrix4.identity()..scale(perspectiveAnimation.value),
            alignment: Alignment.center,
            child: child,
          );
        },
        child: child,
      );
    },
  ),
);


26. Wave Effect

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var waveAnimation = Tween(begin: -0.5, end: 0.5).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeInOut),
      );

      return AnimatedBuilder(
        animation: waveAnimation,
        builder: (context, child) {
          return Transform(
            transform: Matrix4.rotationZ(waveAnimation.value),
            alignment: Alignment.center,
            child: child,
          );
        },
        child: child,
      );
    },
  ),
);


27. Text Fade-In with Delay

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => MemoryDetailPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Adjust the curve and timing for smoother transition
      var fadeInTextAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,  // Use a smooth, ease-out curve
        ),
      );

      return FadeTransition(
        opacity: fadeInTextAnimation,
        child: child,
      );
    },
  ),
);



28. Shimmer Effect

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: child,
      );
    },
  ),
);


29. Morphing Path Animation

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var pathAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.linear),
      );

      return AnimatedBuilder(
        animation: pathAnimation,
        builder: (context, child) {
          return ClipPath(
            clipper: MorphingClipper(pathAnimation.value),
            child: child,
          );
        },
        child: child,
      );
    },
  ),
);


30. Random Floating Effect

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var randomFloat = Tween(begin: Offset(0.0, 0.0), end: Offset(0.1, 0.1)).animate(
        CurvedAnimation(parent: animation, curve: Curves.elasticOut),
      );

      return AnimatedBuilder(
        animation: randomFloat,
        builder: (context, child) {
          return Transform.translate(
            offset: randomFloat.value,
            child: child,
          );
        },
        child: child,
      );
    },
  ),
);


31. Bounce-Out (Vertical)

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var bounceOutAnimation = Tween(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: secondaryAnimation, curve: Curves.bounceOut),
      );

      return ScaleTransition(
        scale: bounceOutAnimation,
        child: child,
      );
    },
  ),
);


32. Pulse Effect

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var pulseAnimation = Tween(begin: 0.9, end: 1.1).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeInOut),
      );

      return ScaleTransition(
        scale: pulseAnimation,
        child: child,
      );
    },
  ),
);


33. Vibration Effect

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var vibrationAnimation = Tween(begin: 0.0, end: 5.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.elasticIn),
      );

      return AnimatedBuilder(
        animation: vibrationAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(vibrationAnimation.value, 0.0),
            child: child,
          );
        },
        child: child,
      );
    },
  ),
);


34. Fall-In Effect

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var fallInAnimation = Tween(begin: -1.0, end: 0.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.decelerate),
      );

      return SlideTransition(
        position: fallInAnimation,
        child: child,
      );
    },
  ),
);


35. Spinning Effect

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var spinAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeIn),
      );

      return AnimatedBuilder(
        animation: spinAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: spinAnimation.value * 2 * 3.141592653589793,
            child: child,
          );
        },
        child: child,
      );
    },
  ),
);


36. Shifting Effect (Diagonal Slide)

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var shiftAnimation = Tween(begin: Offset(-1.0, -1.0), end: Offset.zero).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeInOut),
      );

      return SlideTransition(
        position: shiftAnimation,
        child: child,
      );
    },
  ),
);


37. Elastic Slide-In

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var elasticSlideInAnimation = Tween(begin: Offset(-1.0, 0.0), end: Offset.zero).animate(
        CurvedAnimation(parent: animation, curve: Curves.elasticIn),
      );

      return SlideTransition(
        position: elasticSlideInAnimation,
        child: child,
      );
    },
  ),
);


38. Shake Effect

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var shakeAnimation = Tween(begin: 0.0, end: 15.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.elasticIn),
      );

      return AnimatedBuilder(
        animation: shakeAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(shakeAnimation.value, 0.0),
            child: child,
          );
        },
        child: child,
      );
    },
  ),
);


39. Swing-In

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var swingInAnimation = Tween(begin: -0.2, end: 0.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOut),
      );

      return AnimatedBuilder(
        animation: swingInAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: swingInAnimation.value,
            child: child,
          );
        },
        child: child,
      );
    },
  ),
);


40. Tilt Effect (X-Axis)

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var tiltAnimation = Tween(begin: 0.0, end: 0.2).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeIn),
      );

      return AnimatedBuilder(
        animation: tiltAnimation,
        builder: (context, child) {
          return Transform(
            transform: Matrix4.rotationX(tiltAnimation.value),
            alignment: Alignment.center,
            child: child,
          );
        },
        child: child,
      );
    },
  ),
);


41. Waving Effect

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var waveAnimation = Tween(begin: -0.2, end: 0.2).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeInOut),
      );

      return AnimatedBuilder(
        animation: waveAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: waveAnimation.value * 2.0 * 3.14,
            child: child,
          );
        },
        child: child,
      );
    },
  ),
);


42. Ripple Effect

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var rippleAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeInOut),
      );

      return AnimatedBuilder(
        animation: rippleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: rippleAnimation.value,
            child: child,
          );
        },
        child: child,
      );
    },
  ),
);


43. Flash Transition

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var flashAnimation = Tween(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeIn),
      );

      return AnimatedBuilder(
        animation: flashAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: flashAnimation.value,
            child: child,
          );
        },
        child: child,
      );
    },
  ),
);


44. 3D Flip Effect

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var flipAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeInOut),
      );

      return AnimatedBuilder(
        animation: flipAnimation,
        builder: (context, child) {
          return Transform(
            transform: Matrix4.rotationY(flipAnimation.value * 3.14),
            alignment: Alignment.center,
            child: child,
          );
        },
        child: child,
      );
    },
  ),
);


45. Bounce and Zoom Effect

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var bounceZoomAnimation = Tween(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.bounceInOut),
      );

      return ScaleTransition(
        scale: bounceZoomAnimation,
        child: child,
      );
    },
  ),
);


46. Diagonal Slide-Out

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var diagonalSlideOutAnimation = Tween(begin: Offset.zero, end: Offset(1.0, 1.0)).animate(
        CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOut),
      );

      return SlideTransition(
        position: diagonalSlideOutAnimation,
        child: child,
      );
    },
  ),
);


47. Morphing Transition

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var morphAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.decelerate),
      );

      return AnimatedBuilder(
        animation: morphAnimation,
        builder: (context, child) {
          return ClipPath(
            clipper: MorphingClipper(morphAnimation.value),
            child: child,
          );
        },
        child: child,
      );
    },
  ),
);


48. Wave-In (Horizontal Slide)

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var waveInAnimation = Tween(begin: -1.0, end: 0.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeInOut),
      );

      return SlideTransition(
        position: waveInAnimation,
        child: child,
      );
    },
  ),
);


49. Flip-Out Effect (Y-Axis)

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var flipOutAnimation = Tween(begin: 0.0, end: -1.0).animate(
        CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOut),
      );

      return AnimatedBuilder(
        animation: flipOutAnimation,
        builder: (context, child) {
          return Transform(
            transform: Matrix4.rotationY(flipOutAnimation.value * 3.14),
            alignment: Alignment.center,
            child: child,
          );
        },
        child: child,
      );
    },
  ),
);


50. Center Zoom-Out

Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SettingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var zoomOutAnimation = Tween(begin: 1.0, end: 0.8).animate(
        CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOut),
      );

      return ScaleTransition(
        scale: zoomOutAnimation,
        child: child,
      );
    },
  ),
);

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------