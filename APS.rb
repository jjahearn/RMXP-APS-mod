=begin
 * -------------------------------------------------------
 * Comment out line 276 of Scene_Battle 1 
 * Comment out line 54 of Scene_Battle 4
 * Line 31 of Scene_Battle 3 change to:
 *    if @actor_index == 0
 * Comment out line 269 of Game_Enemy
 * Line 116 of Scene_Battle 4 change to:
 *    start_phase3 
 * game variables 49 and 50, animations 83+, and common events 4 and 7
 * -------------------------------------------------------
  
=end

#--------------------------------------------------------------------------
# * Formulae for our system
#--------------------------------------------------------------------------
module Aps
  #--------------------------------------------------------------------------
  # * determine the cost of upgrading
  #--------------------------------------------------------------------------
  def Aps.upgrade_cost
    n = $game_variables[50]
    return n*2
  end
  #--------------------------------------------------------------------------
  # * enough sp to upgrade?
  #--------------------------------------------------------------------------
  def Aps.can_upgrade?
    return $game_party.actors[0].sp >= upgrade_cost
  end
  #--------------------------------------------------------------------------
  # * determine the cost of healing
  #--------------------------------------------------------------------------
  def Aps.heal_cost
    n = $game_variables[50] #upgrades
    m = $game_variables[49] #uprates
    return n + ( 2 * m )
  end
  #--------------------------------------------------------------------------
  # * enough sp to heal?
  #--------------------------------------------------------------------------
  def Aps.can_heal?
    return $game_party.actors[0].sp >= heal_cost
  end
  #--------------------------------------------------------------------------
  # * determine the cost of Uprate
  #--------------------------------------------------------------------------
  def Aps.uprate_cost
    n = $game_variables[49]
    return ( n + 1 )**3
  end
  #--------------------------------------------------------------------------
  # * enough sp to Uprate?
  #--------------------------------------------------------------------------
  def Aps.can_uprate?
    return $game_party.actors[0].sp >= uprate_cost
  end
  #--------------------------------------------------------------------------
  # * determine the cost of Nuke
  #--------------------------------------------------------------------------
  def Aps.nuke_cost
    n = $game_variables[50] #number of upgrades
    m = $game_variables[49] #number of uprates
    return n + ( 2 * m )
  end
  #--------------------------------------------------------------------------
  # * enough sp to Nuke?
  #--------------------------------------------------------------------------
  def Aps.can_nuke?
    return $game_party.actors[0].sp >= nuke_cost
  end
  #--------------------------------------------------------------------------
  # * determine battler's initial rate of attack
  #--------------------------------------------------------------------------
  def Aps.start_rate
    rate = 100 - rand(50)- rand(50)
    if rate > 0
      return rate
    else
      return 1
    end
  end
  #--------------------------------------------------------------------------
  # * determine battler's ongoing rate of attack in # of frames between attacks
  #--------------------------------------------------------------------------
  def Aps.rate(agility)
    rate = 130 - 43 * Math.log10(agility+1)
    rate = rate.to_i
    if rate > 0 
      return rate
    else
      return 1
    end
  end
  #--------------------------------------------------------------------------
  # * ratio of damage to upgrade pts gained
  #--------------------------------------------------------------------------
  def Aps.gain_up(damage)
    #return damage/30
    up = 1 + $game_variables[49]
    return up
  end
end