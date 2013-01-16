Pushing content out of the way of the keyboard can be pretty troublesome on iOS. The frame you get is in portrait screen space, all the notifications fire when the device rotates, and you have to assemble your own animation block if you want to match the keyboards animation.

KGKeyboardChangeManager handles all of this for you with a couple simple observer blocks.

Be sure to check out the sample project for an example of how to match a view to the frame of the keyboard as it shows, hides, and rotates.