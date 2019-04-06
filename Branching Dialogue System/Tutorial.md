# Branching Dialog System

Hey Guys! In this tutorial I'll teach how to implement a branching dialog system on Godot 3.1 with a dynamic GUI, meaning it responds accordingly to the number of dialog options presented.

![](Pictures/Pic1.gif)
 
The way we go about it is by using the [Dialog Graph Plugin](https://github.com/ejnij/Godot-DialogGraphPlugin/) made by the user [ejnij](https://github.com/ejnij). To get the plugin from **inside** godot you must:

1. Go to **AssetLib**
2. Search for **Dialog Graph Plugin**
3. Click **Download** and then **Install**
4. Go to **Project>Project Settings>Plugins** and enable the dialog graph plugin

After that, the **Dialog Manager** node should appear on the **Create New Node** search bar:

![](Pictures/Pic2.gif)

## Creating New Dialog

The way you create the actual dialog is pretty straightforward, and the [README](https://github.com/ejnij/Godot-DialogGraphPlugin/blob/master/README.md) file on the plugin page explains it quite well. Since that's the case, I'll go over it quickly but will not get into much detail

To create a dialog just **click the "Dialog Manager" node** and then on **"Dialog Graph Editor"** on the bottom of the screen, right next to the animation tab.

![](Pictures/Pic3.gif)

You'll see this tab pop up, and to start creating dialog just click the **"Conversation"** button on the **top left-hand corner** of the tab. You can click on **"Speech"** to create a line of dialog. To connect the line you just wrote to the conversation, just **drag from the yellow dot on the right of the conversation node to the dot on the left of the speech node.**

By connecting these nodes, you can create your conversation. To add options to the choices you create, click the "+" button on the node. The **"Condition"** node is similar to a choice, but checks a boolean variable. **The path to the variable is relative to the parent of the Dialog Manager.** The **"Mux"** functions by feeding multiple paths back to a single node. You can have multiple conversations on a single file, and the **"Jump"** node jumps to a given conversation**. You can also access them by code.

For this tutorial we'll create an example dialog that uses every node. For more detailed descriptions of the nodes please refer to the [original repo](https://github.com/ejnij/Godot-DialogGraphPlugin/).

![](Pictures/Pic4.PNG)

The graph might be a little too much to follow but remember our system is supposed to work with every dialog created, so you can create one however you like.

## Displaying Our Dialog

Let's get to the fun part! First we need the GUI elements to display our text. I'm gonna be using a **"Panel"** and a **"Label"**. Add both of them and adjust the hierarchy so it looks like this:

![](Pictures/Pic5.PNG)

You should also adjust the panel and label size and position to your liking. Note that moving GUI elements around can be tricky as they don't work like other 2d nodes, so if you have any questions please refer to the [docs](http://docs.godotengine.org/en/3.1/tutorials/gui/) or other tutorials. Mine looks like this:

![](Pictures/Pic6.PNG)

Let's attach a **new script** to the panel and start displaying some text. The first thing we have to do is **create an access point to the dialog manager**, and make sure the function `start_dialog()` is called whenever we enter this scene. We also need to connect the Dialog Manager's `new_speech` signal to our panel script, to make sure we know what text to show when our story progresses. Then, it's necessary to **create an access point to our label** and assign the new lines of text to it.

![](Pictures/Connect_new_speech_to_panel.gif)

```gdscript
extends Panel

onready var dialog_manager = $DialogManager
onready var dialog_text_box : Label = $Label

func _ready():
	dialog_manager.start_dialog()
	

func _on_DialogManager_new_speech(speech_codes):
	dialog_text_box.text = speech_codes[0]
	pass
```
As you might have noticed, we receive an array of speeches from the manager. That is due to a translation functionality. Since we won't be using it here, **we will only 
assign the first item of the array to the label.**

If you run the scene, you should see the first line of dialog on the panel.

![](Pictures/Pic7.PNG)

## Dialog Progression

Great! But how do advance the dialog? We need to choose a type of user input to trigger it. In this example I'll go with a mouse click on the panel area because it seems intuitive to me. This is pretty easy to change so if your game doesn't use a mouse a space bar press also works great.

**Theres a default signal from the panel node we can connect to the script to tell us when an input event occurs.**

![](Pictures/Pic8.gif)

The thing is, a mouse click is not defined as a default input. So we need to open **Project Settings>Input Map** and add it.

![](Pictures/Pic9.gif)

After that is set up, we can write the body of the `_on_Panel_gui_input(event)` function.

```gdscript

func _on_Panel_gui_input(event):
	if  event.is_action_pressed("mouse_click"):
		dialog_manager.continue_dialog()

```
Now we should be able to advance to another line of speech.

![](Pictures/Pic10.gif)

You can see that if you try and click again, nothing will happen. That is because the **next node in the dialog is a choice**, and we need some more code for that.

## Choices and Buttons

First connect the signal `_new_choice` from **dialog manager** to the **panel** the same way we did to `_gui_input`.

Since the number of buttons is **dynamic** we want to create a dictionary to store them, so we can create and free them as necessary. 

The argument `choices` received by `_on_DialogManager_new_choice` is an array of strings of the options the player can choose. Their indexes are the same on the processing on the `Dialog Manager` node, so when the player chooses one of them, **We should get the index on the `choices` vector to tell the dialog manager wich choice was picked**.

Since we'll generate the buttons by code, we need to make sure they are instanced in the correct positions. For that reason we're gonna **add a 
VBoxContainer** to our tree to have the buttons spawn nicely one under another.

By now the tree should look like this:

![](Pictures/Tree_with_vboxc.PNG)

Now let's go over the code:

```gdscript

onready var choice_container : VBoxContainer = $VBoxContainer

var choice_buttons = {}

func _on_DialogManager_new_choice(choices):
	if choice_buttons.empty():
		var choice_index = 0
		for choice in choices:
			choice_buttons[choice_index] = Button.new()
			choice_container.add_child(choice_buttons[choice_index])
			choice_buttons[choice_index].text = choice
			choice_index += 1


```

Straight away we **store the access point to our _VBox_ in a variable** (don't forget static typing! It's good for you and the environment).

Since `choices` are the actual values of the strings, as our `for` loop will go over them, we need to count the index ourselves, by creating a `choice_index` variable.

What we're doing basically is, to each choice, we add an instance of the class `Button` to our dictionary in the same index as the `choices` vector. We then add them as children of the `choice_container` and assign their text to the buttons. Finally, we increase `choice_index`.

![](Pictures/Options_shown.gif)

But clicking the options doesn't actually do anything. What do we need?

**More code.**

Since the buttons are generated through code, we can't connect the `pressed()` signal to pre-existing functions, as we don't know how many buttons there will be. Hence, we're going to check in the `_process` function if a button has been pressed. Remember every button is stored in the dicitonary, so we can just go through tem in a `for` loop. 

```gdscript
func _process(delta):
	for button in choice_buttons:
		if choice_buttons[button].pressed:
			dialog_manager.choice_picked(button)

```

![](Pictures/Options_dont_disappear.gif)

Notice that even though the dialog advances, the buttons don't disappear after we click them. To fix this we're gonna check if the buttons list is currently empty, and if not, delete the buttons and empty the list. We'll do this inside `_on_DialogManager_new_speech` because that's when a new dialog is coming.

```gdscript
func _on_DialogManager_new_speech(speech_codes):
	if !choice_buttons.empty():
		for button in choice_buttons:
			choice_buttons[button].queue_free()
		choice_buttons.clear()
	dialog_text_box.text = speech_codes[0]
```

Every thing seems to be working fine! This is already a functioning system, but there's a couple last things I want to show you.

## Conditional Branching

Maybe you don't your player to see a certain choice if he doesn't have a certain item, or didn't choose the correct option on a prior choice. The way this plugin handles it is by checking a boolean variable. **The path to the variable is relative to the parent of the dialog manager node.**

If you explored the options of our dialog file until now, you might have come across some nonsense about soup. Something along the lines of *"I would never offer you soup"*. But maybe the player likes soup? Maybe they'd like some delicious soup. There's **literally** no way of knowing. How can we ever find out? If there only was checkbox they could tick to indicate their likness of soup. Hmmm... 🤔

Maybe... 

![](Pictures/Soup_added.PNG)

Go on and add a check box or whatever sort of button you like, and some text to your liking also. To access this in our panel script, we create an access point, and save its condition to a variable in `_process(delta)`. Pretty simple.

```gdscript
onready var soup_pressed : CheckBox = $CheckBox

var soup_pressed

func _process(delta):
	soup_pressed = soup_check_box.pressed
	for button in choice_buttons:
		if choice_buttons[button].pressed:
			dialog_manager.choice_picked(button)
```
Remember in the dialog we created, **the Condition node already had `soup_pressed` as the variable.**

Cool! What now?

## Ending The Dialog

When your dialog has ended, you probably want to have the panel disappear. Just connect the Dialog Manager's `dialog_finished` signal to the panel and delete it!

```gscript
func _on_DialogManager_dialog_finished():
	queue_free()
```
That's pretty much it!

 Thank you for reading and until next time! :^)
