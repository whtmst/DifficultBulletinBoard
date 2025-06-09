# Difficult Bulletin Board - Addon for Turtle WoW

**Difficult Bulletin Board** is a World of Warcraft 1.12 addon inspired by the LFG Group Bulletin Board. It scans world chat and organizes messages into an easy-to-read UI, making it more convenient to find what you need.

## Features

- **Group Finder**: Easily locate groups for the content you want to do.
- **Groups Logs**: Track and filter all group-related messages in one consolidated view.
- **Profession Search**: Quickly find players offering or seeking crafting services.
- **Hardcore Messages**: Stay updated with hardcore-related events, such as deaths or level-ups.
- **Hardcore-Only Chat Filter**: Show only messages aimed at hardcore characters.
- **Blacklist Filter**: Hide all messages matching your blacklist.
- **Expiration Date**: Set an expiration date to automatically delete old messages—or turn automatic deletion off entirely.
- **Collapsible Topics**: Collapse topics to hide unwanted messages and keep your feed tidy.
- **Notification System**: Be notified if an entry gets added to a specific topic.

### Group Finder

![groups](https://github.com/user-attachments/assets/59403fa8-df0c-4136-9a40-8c0bc2c61e1b)



### Group Logs

![groups logs](https://github.com/user-attachments/assets/b1da8aba-0f01-48ff-8cdd-67d91b81d9c4)



### Profession Search

![professions](https://github.com/user-attachments/assets/c2a1ed20-a78c-4485-bcc4-e32f6b2d6cac)



### Hardcore Messages

![hardcore](https://github.com/user-attachments/assets/5c2a96c9-14d3-4c5f-a745-d96469043f3c)



## Settings

![settings](https://github.com/user-attachments/assets/b5cc8ec3-367e-4bb7-862e-4f966027ee49)



## Installation

1. Download the addon by clicking the link below:
   - [Download Difficult Bulletin Board](https://github.com/DeterminedPanda/DifficultBulletinBoard/archive/refs/heads/master.zip)

2. Unzip the `DifficultBulletinBoard-master.zip` archive.

3. Rename the directory inside the zip from `DifficultBulletinBoard-master` to `DifficultBulletinBoard`.

4. Move the `DifficultBulletinBoard` folder to your World of Warcraft AddOns directory:
   - Example path: `C:\World of Warcraft Turtle\Interface\AddOns`

5. If you have WoW open, make sure to restart the game for the addon to load properly.

6. To verify the installation, type `/dbb` in the game chat. If the installation was successful, the addon will open.


## Usage

### Accessing the Bulletin Board

You can open the bulletin board interface by left-clicking on the DifficultBulletinBoard Minimap icon or by typing ```/dbb``` into your chat window.
The interface will show an ordered list of messages from the world chat.

### Editing and Managing Entries

To manage topics, right-click the minimap icon to open the options window and select which topics to follow by selecting or unselecting the corresponding checkbox.

## Troubleshooting

### No Messages Show Up?
If no messages appear on your bulletin board and no errors are displayed, make sure you are in the **world chat** by typing `/join world` in-game.

### Tags List Issues?
If your tags list seems incorrect or disorganized, try pressing the **Reset** button in the options window.  
It’s also a good idea to reset the tags after updating the addon, as I may improve or adjust the tags list in future updates.

## Contact

Have feature suggestions or need further assistance? Feel free to [create an issue](https://github.com/DeterminedPanda/DifficultBulletinBoard/issues) on this repository and I will help you as soon as possible.


## To-Do List:

- [x] Ensure that when a person already in the list sends a new message, their old entry is removed and they are moved to the top of the list.
- [x] Add a reset button to the options frame.
- [x] Expand options (e.g., placeholder number adjustments, etc.).
- [x] Implement left-click whisper, shift-left-click /who, and right-click /invite functionality for buttons
- [x] Implement tabs
- [x] Implement a tab for Hardcore messages
- [ ] Implement more customization options (e.g., classic WoW border styles, etc.).
