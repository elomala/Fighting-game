<h1 align="center">FIGHTING GAME</h1>
This is a <a href="https://www.roblox.com/games/2166055981/Fighting-game">project</a> I started working on in late 2022. This is one of my very first projects in which I knew what I was doing.<br>
I made multiple projects a while back but none of them were completed. <a href="https://www.roblox.com/games/2166055981/Fighting-game">This game</a> is also, not complete but it is playable.
<br>This game has a <a href="https://trello.com/b/XfQLXXVA/fighting-game">Trello</a> which describes the abilities of the classes. You can also access the info in-game.<br>
In this repository, I shall be uploading the hit-handler script. I used a module named <b>MuchachoHitbox</b> for basic hitbox generation. Everything else in this game is made by me. The hitboxes and hit detection are all server-sided.
<h2>Fighting System</h2>
There are multiple functionalities in the game which are described below:<br>
<ul>
    <li><b>Basic Stats:</b></li>
    <ul> 
      <li><b>Health:</b> Amount of Damage a player can take before dying</li>
        <li><b>Health Regeneration:</b> Regeneration starts after 7 seconds of not being attacked. The amount of health regenerated per tick depends upon the player's max health and missing health.</li>
      <li><b>Stamina:</b> Some functions like jumping and dashing require stamina. Stamina regeneration depends on health to prevent players from running easily.</li>
      <li><b>Walkspeed:</b> Every class has a different walkspeed depending on its play style. Classes with high health usually have low walkspeed and vice versa.</li><img src="/Pictures/Basic.png" alt="basic" title="Basic Stuff">
    </ul>
    <li><b>Blocking:</b></li>
    Some attacks can be blocked. A player's walkspeed is greatly reduced while blocking and they can't attack. Guardbreak attacks can shatter an opponent's guard leaving them stunned for some time. Guardbreak attacks have an exclamation mark on top of the user's head. Attacking a blocking player from behind bypasses their block.<br>
    <img src="/Pictures/Blocking.png" alt="Block" title="Sword dude defending himself">
    <li><b>Attacking:</b></li>
  A specific class has an auto combo, a guardbreak, and three special attacks. Details can be seen on the <a href="https://trello.com/b/XfQLXXVA/fighting-game">Trello</a> page.<br>
    Here are some snapshots of epic moves!
    <img src="/Pictures/PoorZombie.png" alt="Zombie" title="Poor Zombie getting hit by big punch!">
    <img src="/Pictures/sheriff.jpg" alt="sheriff" title="Sherrif using his guardbreak">
    <img src="/Pictures/Savage.png" alt="Savage" title="Savage charging his attack">
</ul>
