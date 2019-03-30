# Branching Dialog System

Hey Guys! In this tutorial I'll teach how to implement a branching dialog system on Godot 3.1 with a dynamic GUI, meaning it responds accordingly to the number of dialogue options presented.

![](Pic1.gif)
 
The way we go about it is by using the [Dialog Graph Plugin](https://github.com/ejnij/Godot-DialogGraphPlugin/) made by the user [ejnij](https://github.com/ejnij). To get the plugin from **inside** godot you must:

1. Go to **AssetLib**
2. Search for **Dialog Graph Plugin**
3. Click **Download** and then **Install**
4. Go to **Project>Project Settings>Plugins** and enable the dialog graph plugin

After that, the **Dialog Manager** node should appear on the **Create New Node** search bar:

![](Pic2.gif)

## Creating New Dialog

The way you create the actual dialog is pretty straightforward, and the [README](https://github.com/ejnij/Godot-DialogGraphPlugin/blob/master/README.md) file on the plugin page explains it quite well. But since I'm already doing the tutorial I tought I might as well go through this.

To create a dialog just **click the Dialog Manager node** and then on **Dialog Graph Editor** on the bottom of the screen, right next to the animation tab.