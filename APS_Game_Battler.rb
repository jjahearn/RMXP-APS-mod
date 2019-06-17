=begin

  This page modifies the game's battler code, adding derived attributes that
  track APS 

=end

#--------------------------------------------------------------------------
# * Adding code to the game's in-battle characters
#--------------------------------------------------------------------------
class Game_Battler
  attr_accessor :apstimer
  attr_accessor :apsrate
  #--------------------------------------------------------------------------
  # * adding to the constructor method
  #--------------------------------------------------------------------------
  alias :default_initialize :initialize
  def initialize
    default_initialize
    @apstimer = aps_start_rate
  end
  #--------------------------------------------------------------------------
  # * process an incoming attack
  #--------------------------------------------------------------------------
  alias :default_attack_effect :attack_effect
  # in this system, the defender processes the attacker.
  # it's just an artifact of the default system :-|
  # process the attack 
  def attack_effect(attacker)
    default_attack_effect(attacker)
    self.animation_id = attacker.animation2_id
    unless self.damage == "Miss"
      attacker.sp += Aps.gain_up(self.damage)
    end
  end
  #--------------------------------------------------------------------------
  # * determine battler's initial rate of attack
  #--------------------------------------------------------------------------
  def aps_start_rate
    return Aps.start_rate
  end
  #--------------------------------------------------------------------------
  # * determine battler's ongoing rate of attack
  #--------------------------------------------------------------------------
  def aps_rate
    return Aps.rate(self.agi)
  end
  #--------------------------------------------------------------------------
  # * Recover All override: restore party HPs without changing SP
  #--------------------------------------------------------------------------
  def recover_all
    @hp = maxhp
    #@sp = maxsp
    for i in @states.clone
      remove_state(i)
    end
  end
end