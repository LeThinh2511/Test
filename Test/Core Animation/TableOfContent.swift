//
//  TableOfContent.swift
//  Test
//
//  Created by Thinh Le on 5/16/20.
//  Copyright © 2020 Techchain. All rights reserved.
//

/*

 MARK: Section I: Animations with SwiftUI
    Description: - SwiftUI is a modern, cross-platform, declarative UI framework from Apple introduced in 2019 in iOS13. SwiftUI supports all Apple platforms, so as a cool bonus anything you learn in this section can be applied verbatim for any of your tvOS, macOS, iPadOS, and watchOS apps! Focusing on the iOS support of SwiftUI, it's important to mention that this framework is iOS13+ only. That means that any apps using SwiftUI cannot be run on earlier versions of iOS. If you choose to support only iOS13 or newer - you're in luck. You can use this amazing new way to create your layout and animations. In case you need to support versions older than iOS13 - working through this section is still going to be tons of fun. Additionally, building up some experience with SwiftUI will be a great way to get yourself ready for when the framework is more widely adopted.
 
 1.1: Introduction to Animations with SwiftUI:
 In this chapter you will learn about the very basics of SwiftUI animations and then quickly move onto to more complex and visually interesting animations in a real life project.
 
 1.2: Intermediate SwiftUI Animations:
 In this chapter you will learn about the very basics of SwiftUI animations and then quickly move onto to more complex and visually interesting animations in a real life project.
 
 MARK: Section II: View Animations
    Description: These five chapters will introduce you to the animation API of UIKit. This API is specifically designed to help you animate your views with ease while avoiding the complexity of Core Animation, which runs the animations under the hood. Though simple to use, the UIKit animation API provides you with lots of flexibility and power to handle most, if not all, of your animation requirements. Animations are visible, onscreen effects that apply to all of the views, or visible objects, in your user interface.
 
 2.1: Getting Started with View Animations:
 You’ll learn how to move, scale and fade views. You’ll create a number of different animations to get comfortable with Swift and the basic UIKit APIs.
 
 2.2: Springs:
 You’ll build on the concepts of linear animation and create more eye-catching effects using spring-driven animations. Boiiing!
 
 2.3: Transitions:
 You’ll learn about several class methods in UIKit that help you animate views in or out of the screen. These one-line API calls make transition effects easy to achieve.
 
 2.4: View Animations in Practice:
 This chapter teaches you how to combine techniques you’ve already learned in creative ways to build up even cooler animations.
 
 2.5: Keyframe Animations:
 You’ll use keyframe animations to unlock the ultimate achievement of an impressive UI: creating elaborate animation sequences built from a number of distinct stages.
 
 MARK: Section III: Auto Layout
    Description: Auto Layout has been around for a while now – it was first introduced in iOS 6 and has gone through a series of successful iterations with each release of iOS and Xcode. The core idea behind Auto Layout is incredibly simple: it lets you define the layout of the UI elements of your app based on relationships you create between each of the elements in the layout. Although you may have used Auto Layout for static layouts, you’ll go beyond that in this section and work with constraints in code to animate them!
 
 3.1: Introduction to Auto Layout:
 This is a crash course on Auto Layout in case you’re not familiar with it already; you’ll need this for the next chapter.
 
 3.2: Animating Constraints:
 Once you’ve worked through the project in Chapter 6, you’ll add a number of animations to it and put your newfound knowledge to good use.
 
 MARK: Section IV: Layer Animations
    Description: Now that you are proficient in creating view animations, it’s time to dig a bit more deeply and look into the Core Animation APIs on a lower, more powerful level. In this section of the book, you’ll learn about animating layers instead of views and how to make use of special layers.

 4.1 Getting Started with Layer Animations:
 You’ll start with the simplest layer animations, but also learn about debugging animations gone wrong.
 
 4.2 Animation Keys & Delegatesa:
 Here you gain more control over the currently running animations and use delegate methods to react to animation events.
 
 4.3 Groups & Advanced Timing:
 In this chapter you combine a number of simple animations and run them together as a group.
 
 4.4 Layer Springs:
 In this chapter you learn how to use `CASpringAnimation` to create powerful and flexible spring layer animations.
 
 4.5 Keyframe Animations & Struct Properties:
 Here you’ll learn about layer keyframe animations, which are powerful and slightly different than view keyframe animations. There’s some special handling around animating struct properties, which you’ll also learn about.
 
 4.6 Shapes & Masks:
 Draw shapes on the screen via CAShapeLayer and animate its special path property.
 
 4.7 Gradient Animations:
 Learn how to use CAGradientLayer to help you draw and animate gradients.
 
 4.8 Stroke & Path Animations:
 Here you will draw shapes interactively and work with some powerful features of keyframe animations.
 
 4.9 Replicating Animations:
 Learn about the little known but powerful CAReplicatorLayer class.
 
 MARK: Section V: View Controller Transition Animations
    Description: By now you know how to create a wide range of beautiful animations for your apps. You’ve experimented with moving, scaling and fading views, animating different types of layers – and a whole lot more. It’s time to learn how to use these animation techniques in the broader context of app navigation and layout. You’ve animated multiple views and layers already, but now take a bigger-picture perspective and think about animating entire view controllers!
 
 5.1 Custom Presentation Controller & Device Orientation Animationsa:
 Learn how to present view controllers via custom animated transitions.
 
 5.2 UINavigationController Custom Transition Animationsa:
 You’ll build upon your skills with presenting view controllers and develop a really neat reveal transition for a navigation controller app.
 
 5.3 Interactive UINavigationController Transitions:
 Learn how to make the reveal transition interactive: the user will be able to scrub back and forth through the animated transition!
 
 MARK: Section VI: Animations with UIViewPropertyAnimator
    Description: UIViewPropertyAnimator is a class introduced in iOS10, which helps developers create interactive, interruptible view animations. When you run animations via an animator, you have the possibility to adjust those animations on the fly - you can pause, stop, reverse, and alter the speed of animations that are already running. In this section of the book, you are going to work on a project featuring plenty of different view animations, which you are going to implement by using UIViewPropertyAnimator.
 
 6.1 Getting Started with UIViewPropertyAnimator:
 Learn how to create basic view animations and keyframe animations. You’ll look into using custom timing that goes beyond the built-in easing curves.
 
 6.2 Intermediate Animations with UIViewPropertyAnimator
 In this chapter you are going to learn about using animators with Auto Layout. Further, you will learn how to reverse animations or make additive animations for smoother changes along the way.
 
 6.3 Interactive Animations with UIViewPropertyAnimator
 Learn how to drive your animations interactively based on the user’s input. For extra fun you’ll look into both basic and keyframe animations interactivity.
 
 6.4 UIViewPropertyAnimator View Controller Transitions:
 Create custom View Controller transitions using a UIViewPropertyAnimator to drive the transition animations. You will create both static and interactive transitions.
 
 MARK: Section VII: 3D Animations
    Description: This section of the book will show you how to position and rotate layers in 3D space. You’ll work with a special property of CATransform3D: namely, the transformation class applied to layers. CATransform3D is similar to CGAffineTransform, but in addition to letting you scale, skew and translate in the x and y directions, it also brings in the third dimension: z. The z-axis runs straight out of the device screen towards your eyes.
 
 7.1 Simple 3D Animations:
 Learn how to set up your layers in 3D space, how to choose the distance from the camera to your layer, and how to create animations in your 3D scene.
 
 7.2 Intermediate 3D Animations:
 Go further into 3D space and learn about some of the more advanced ways to create 3D Animations.
*/
