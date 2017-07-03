function enableTesting(event)
	game.players[event.player_index].cheat_mode = true
	game.players[event.player_index].force.research_all_technologies()
end
commands.add_command("testing", "Run to enable testing without disabling achievements", enableTesting)

script.on_init(function(e)
	global.trees_destroyed = 0
	global.lamps_placed = 0
	global.solar_panels_placed = 0
end
)

function treeDestroyed(e)
	if e.entity.type == "tree" then
		global.trees_destroyed = global.trees_destroyed + 1 --increment the number of trees destroyed
		if global.trees_destroyed >= 100000 then
			for index, player in pairs(game.players) do
				player.unlock_achievement("deforestation")
			end
		end
	end
end
script.on_event(defines.events.on_player_mined_entity, treeDestroyed)
script.on_event(defines.events.on_robot_pre_mined, treeDestroyed)

function onEntityDied(e)
	local entity = e.entity
	local cause = e.cause
	if not cause then return end
	local causeName = cause.name or "None"
	local causeForce = e.force
	local causeForceName = causeForce.name or "None"

	--Friendly fire - destroy your own building
	if cause and cause.type == "player" and entity.force == causeForce and entity.has_flag("player-creation") then
		cause.player.unlock_achievement("friendly-fire")
	elseif cause and causeForce and cause.name == "gun-turret" and entity.type == "unit" then
		for index, player in pairs(causeForce.players) do
			player.unlock_achievement("tango-down")
		end
	elseif entity.type == "tree" then
		treeDestroyed(e)
	end
end
script.on_event(defines.events.on_entity_died, onEntityDied)

function onBlueprint(e)
	local player = game.players[e.player_index]
	player.unlock_achievement("blueprinted")
end
script.on_event(defines.events.on_player_setup_blueprint, onBlueprint)

function onItemPickup(e)
	local player = game.players[e.player_index]
	player.unlock_achievement("looted")
end
script.on_event(defines.events.on_picked_up_item, onItemPickup)

function onResourceDepleted(e)
	for index, player in pairs(e.entity.force.players) do
		player.unlock_achievement("depleted")
	end
end
script.on_event(defines.events.on_resource_depleted, onResourceDepleted)

function onSettingsPasted(e)
	local player = game.players[e.player_index]
	if player then
		player.unlock_achievement("copy-and-pasted")
	end
end
script.on_event(defines.events.on_entity_settings_pasted, onSettingsPasted)

function onConsoleChat(e)
	local player = game.players[e.player_index]
	if player then
		player.unlock_achievement("hello-world")
	end
end
script.on_event(defines.events.on_console_chat, onConsoleChat)

function onPlayerCrafted(e)
	local item = e.item_stack.name
	local player = game.players[e.player_index]
	if item == "submachine-gun" then
		player.unlock_achievement("fully-automatic")
	elseif item == "rocket-launcher" then
		player.unlock_achievement("maggots")
	elseif item == "flamethrower" then
		player.unlock_achievement("we-didnt-start-the-fire")
	end
end
script.on_event(defines.events.on_player_crafted_item, onPlayerCrafted)

function onPlaced(e)
	if e.created_entity.name == "lamp" then
		global.lamps_placed = global.lamps_placed + 1
		if global.lamps_placed >= 200 then
			for index, player in pairs(game.players) do
				player.unlock_achievement("let-there-be-light")
			end
		end
	elseif e.created_entity.type == "entity-ghost" then
		game.players[e.player_index].unlock_achievement("ghosted")
	elseif e.created_entity.name == "solar-panel" then
		global.solar_panels_placed = global.solar_panels_placed + 1
		if global.solar_panels_placed >= 200 then
			for index, player in pairs(game.players) do
				player.unlock_achievement("praise-the-sun")
			end
		end
	end
end
script.on_event(defines.events.on_built_entity, onPlaced)
script.on_event(defines.events.on_robot_built_entity, onPlaced)

function onResearch(e)
	local research = e.research
	local force = research.force
	if research.name:find("-50") then --A level 50 research
		for index, player in pairs(force.players) do
			player.unlock_achievement("dedication")
		end
	end
end
script.on_event(defines.events.on_research_finished, onResearch)

function onRocketLaunched(event)
	local force = event.rocket.force
	if event.rocket.get_item_count("satellite") == 0 then
		for index, player in pairs(force.players) do
			player.unlock_achievement("you-forgot-something")
		end
	end
end
script.on_event(defines.events.on_rocket_launched, onRocketLaunched)
