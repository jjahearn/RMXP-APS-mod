=begin
 
  This page modifies the battle screen, which controls the actual flow of 
  combat.
  
=end
#--------------------------------------------------------------------------
# * Adding code to the game's battle processing
#--------------------------------------------------------------------------
class Scene_Battle
  #--------------------------------------------------------------------------
  # * adding to the constructor method
  #--------------------------------------------------------------------------
  alias :default_initialize :initialize
  def initialize
    default_initialize
    @battlestart = false
  end
  #--------------------------------------------------------------------------
  # * Call update_aps every frame of the game's main battle loop
  #--------------------------------------------------------------------------
  alias :default_update :update 
  def update
    #run standard battle processing
    default_update
    #unless the battle is starting or ending
    unless @phase == 1 || @phase == 5
      #are we choosing whether to fight or run?
      if @phase == 2
        #is the fight already underway?
        if @battlestart
          update_aps
        end
      else #we have passed phase 2 so the battle has begun
        @battlestart = true
        update_aps
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Run our APS system logic
  #--------------------------------------------------------------------------
  def update_aps
    #get a list of battlers
    @aps_battlers = aps_get_battlers
    for battler in @aps_battlers
      #make a random delay for the starting action
      if battler.apstimer == nil
        battler.apstimer = battler.aps_start_rate
      end
      #if ready to act
      if battler.apstimer == 0
        #do it
        aps_do_action(battler)
        #reset action timer
        battler.apstimer = battler.aps_rate
      else
        #count down to next action
        battler.apstimer -= 1
      end
    end
    #update health display
    @status_window.refresh
    #update cost of upgrading
    @actor_command_window.aps_cost_update
  end
  #--------------------------------------------------------------------------
  # * Make an array of existing battlers
  #--------------------------------------------------------------------------
  def aps_get_battlers
    if aps_enemies_dead?
      judge #determine a win and wrap the battle
      return []
    end
    @dudes = []
    for actor in $game_party.actors
      #if alive 
      if actor.exist?
        #only processing the main character's attacks
        if actor.id == 1
          @dudes.push(actor)
        end
      end
    end
    for enemy in $game_troop.enemies
      #is the enemy alive / visible?
      if enemy.exist?
        @dudes.push(enemy)
      end
    end
    return @dudes
  end
  #--------------------------------------------------------------------------
  # * process an action
  #--------------------------------------------------------------------------
  def aps_do_action(battler)
    #anyone here?
    unless @aps_battlers[0] == nil
      #is the attacker being processed a pc or npc?
      if battler.is_a?(Game_Actor)
        aps_player_action(battler)
      else
        aps_enemy_action(battler)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * process player action
  #--------------------------------------------------------------------------
  def aps_player_action(player)
    #get a random enemy target
    target = $game_troop.random_target_enemy
    #if all enemies dead, process victory
    if target == nil
      judge
    else
      #process attack
      target.attack_effect(player)
      #make damage amount popup
      if target.damage != nil
        target.damage_pop = true
      end
    end
  end
  #--------------------------------------------------------------------------
  # * process enemy action
  #--------------------------------------------------------------------------
  def aps_enemy_action(enemy)
    #get a random enemy target
    target = $game_party.random_target_actor
    #if all actors dead, process victory
    if target == nil
      judge
    else
      enemy.make_action
      if enemy.current_action.kind == 0
        #process attack
        target.attack_effect(enemy)
      else
        @aps_active_battler = enemy
        @aps_target_battlers = []
        aps_make_skill_action_result
        for target in @aps_target_battlers
          target.animation_id = @aps_animation2_id
          if target.damage != nil
            target.damage_pop = true
          end
        end
        if @aps_animation1_id != 0
          enemy.animation_id = @aps_animation1_id
        end
      end
      #make damage amount popup
      if target.damage != nil
        target.damage_pop = true
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Are all the enemies dead?
  #--------------------------------------------------------------------------
  def aps_enemies_dead?
    for enemy in $game_troop.enemies
      #is the enemy alive / visible?
      if enemy.exist?
        return false
      end
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * process an enemy skill
  #--------------------------------------------------------------------------
  def aps_set_target_battlers(scope)
    # If battler performing action is enemy
    if @aps_active_battler.is_a?(Game_Enemy)
      # Branch by effect scope
      case scope
      when 1  # single enemy
        index = @aps_active_battler.current_action.target_index
        @aps_target_battlers.push($game_party.smooth_target_actor(index))
      when 2  # all enemies
        for actor in $game_party.actors
          if actor.exist?
            @aps_target_battlers.push(actor)
          end
        end
      when 3  # single ally
        index = @aps_active_battler.current_action.target_index
        @aps_target_battlers.push($game_troop.smooth_target_enemy(index))
      when 4  # all allies
        for enemy in $game_troop.enemies
          if enemy.exist?
            @aps_target_battlers.push(enemy)
          end
        end
      when 7  # user
        @aps_target_battlers.push(@aps_active_battler)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Make Skill Action Results for enemy.
  #   adapted from Scene_Battle.make_skill_action result
  #--------------------------------------------------------------------------
  def aps_make_skill_action_result
    # Get skill
    @skill = $data_skills[@aps_active_battler.current_action.skill_id]
    # Show skill name on help window
    @help_window.set_text(@skill.name, 1)
    # Set animation ID
    @aps_animation1_id = @skill.animation1_id
    @aps_animation2_id = @skill.animation2_id
    # Set target battlers
    aps_set_target_battlers(@skill.scope)
    # Apply skill effect
    for target in @aps_target_battlers
      target.skill_effect(@aps_active_battler, @skill)
    end
  end
  #--------------------------------------------------------------------------
  # * Make Player Action Results 
  #--------------------------------------------------------------------------
  def make_basic_action_result
    # If upgrade
    if @active_battler.current_action.basic == 0
      @active_battler.sp -= Aps.upgrade_cost
      # Set anaimation ID
      @animation1_id = $data_skills[83].animation1_id #upgrade skill
      @common_event_id = 4 #upgrade event
    end
    # If heal
    if @active_battler.current_action.basic == 1
      @active_battler.sp -= Aps.heal_cost
      # Display "Heal" in help window
      @help_window.set_text("Heal", 1)
      @animation1_id = $data_skills[84].animation1_id #heal skill
      for actor in $game_party.actors
        if actor.exist?
          orig_hp = actor.hp
          actor.recover_all
          actor.damage = orig_hp - actor.hp
          if actor.damage != 0
            actor.damage_pop = true
          end
        end
      end
      return
    end
    # If uprate
    if @active_battler.current_action.basic == 2
      @active_battler.sp -= Aps.uprate_cost
      # Display "Uprate" in help window
      @help_window.set_text("Uprate", 1)
      @animation1_id = $data_skills[85].animation1_id #uprate skill
      $game_variables[49] += 1
      return
    end
    # If nuke
    if @active_battler.current_action.basic == 4
      @active_battler.sp -= Aps.nuke_cost
      @help_window.set_text("Nuke", 1)
      for enemy in $game_troop.enemies
        if enemy.exist?
          orig_hp = enemy.hp
          enemy.hp = (enemy.hp*0.9).round
          enemy.damage = orig_hp - enemy.hp
          if enemy.damage != 0
            enemy.damage_pop = true
          end
          enemy.animation_id = $data_skills[86].animation2_id #uprate skill
        end
      end
      return
    end
  end
  #--------------------------------------------------------------------------
  # * gain one UP for spamming the upgrade command
  #--------------------------------------------------------------------------
  def spam_point
    $game_party.actors[0].sp += 1
  end
  #--------------------------------------------------------------------------
  # * Frame Update (actor command phase : basic command)
  #--------------------------------------------------------------------------
  #alias default_update_phase3_basic_command update_phase3_basic_command
  def update_phase3_basic_command
#    # If B button was pressed
#    if Input.trigger?(Input::B)
#      # Play cancel SE
#      $game_system.se_play($data_system.cancel_se)
#      # Go to command input for previous actor
#      phase3_prior_actor
#      return
#    end
    # If C button was pressed
    if Input.trigger?(Input::C) or Input.trigger?(Input::B)
      # Branch by actor command window cursor position
      case @actor_command_window.index
      when 0  # upgrade
        if Aps.can_upgrade?
          # Play decision SE
          $game_system.se_play($data_system.decision_se)
          # Set action
          @active_battler.current_action.kind = 0
          @active_battler.current_action.basic = 0
          phase3_next_actor
        else
          spam_point
          $game_system.se_play($data_system.cancel_se)
          return
        end
      when 1  # heal
        if Aps.can_heal?
          # Play decision SE
          $game_system.se_play($data_system.decision_se)
          # Set action
          @active_battler.current_action.kind = 0
          @active_battler.current_action.basic = 1
          phase3_next_actor
        else
          spam_point
          $game_system.se_play($data_system.cancel_se)
          return
        end
      when 2  # uprate
        if Aps.can_uprate?
          # Play decision SE
          $game_system.se_play($data_system.decision_se)
          # Set action
          @active_battler.current_action.kind = 0
          @active_battler.current_action.basic = 2
          phase3_next_actor
        else
          spam_point
          $game_system.se_play($data_system.cancel_se)
          return
        end
      when 3  # nuke
        if Aps.can_nuke?
          # Play decision SE
          $game_system.se_play($data_system.decision_se)
          # Set action
          @active_battler.current_action.kind = 0
          @active_battler.current_action.basic = 4
          phase3_next_actor
        else
          spam_point
          $game_system.se_play($data_system.cancel_se)
          return
        end
      end
      return
    end
  end
end