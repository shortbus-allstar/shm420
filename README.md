**Patch Notes - v2.1.3-beta**
1. Added custom UI themes
   
**Patch Notes - v2.1.3-beta**
1. Changed the update script to use a relative directory path instead of the absolute path C:\MQNext
2. Fixed an issue where the condhandler would crash the lua while zoning
3. Fixed an issue where changing pet spells in the GUI would crash the lua
4. Fixed an issue where DoTs and Nukes being cast were linked to the malo setting
   
**Patch Notes - v2.1.2-beta**

1. Fixed an issue where the lua would crash when group members die or zone

**Patch Notes - v2.1.1-beta**

1. Fixed an issue with trying to cure Rez Sicknesses off self

**Patch Notes - v2.1.0-beta**

1. Conditions are now global variables. For example, if you have a condition named "Spire", using

   ```/echo ${Spire}```

   will output 0 if false and 1 if true. This also works using commands as names:

   ```/if (${/multiline ; /mqp ; /cast etc etc}==1) /echo asdf```

   Here is an example using one in a separate shm420 condition:

     ``` Name: Pack of Wurt```
  
   ```Condition: ${If[!${Me.Buff[Pack of Wurt].ID} && !${Select[${Zone.ID},151,202,203,219,344,345,463,737,33480,33113]},1,0]}```

     ``` Name: /echo Pack of Wurt not needed```
  
      ```Condition: ${If[${Pack of Wurt}==0,1,0]}```

      For extra clarity, whatever is inside of the Name: [Input Text] will be what is inside of the ${}.

2. Events tab added. Works similarly to mq2events, currently supports up to 4 args.

   Example:

   ```Cmd: /multiline ; /tar #1# ; /timed 10 /useitem Dradir's Scepter of Dreams```
   
   ```Trigger: #1# is consumed by darkness.'```
   
   ```Cmd Delay: 1200```
   
   ```Loop Delay: 1200```

   More examples included with update

   To delete an event, type the matching command in the new event input text box and click delete event.
   
   When adding an event, the cmd delay is the delay in ms between consecutive executions of that specific command if it is triggered rapidly.
   The loop delay (ms) is how long the main loop should pause itself to let the command run its course.

4. After zoning, return to camp is now turned off.

5. Fixed an issue where the bot would chase the main assist's corpse
   
6. Fixed an issue with target changing for a short time after being paused
   
7. Will now cure detrimental effects with radiant cure (now ignores rez sicknesses too)
   
8. Fixed rez routine (again) (hopefully?)

9. Will now skip condition-activated abilities when slowing a named mob (the same way it would handle a heal or rez ability)


**Patch Notes - v2.0.0-beta**

1. Changed burn tab to conditions tab (basically a more versatile burn tab)

2. Fixed Wild growth to not cast in passive zones

3. Fixed an issue with chase navigating on top of your assist instead of the chase distance amount away

4. Fixed an issue with cripple / feralize logic

5. Fixed an issue with rez routine (hopefully?)

6. Improved the queue function, noticeably faster casting

