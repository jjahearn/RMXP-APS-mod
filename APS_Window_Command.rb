=begin

  This page modifies the player's in-battle command window.
  
  aps_cost_update calls methods that are only slightly different from
  the default Window_Command methods. These methods add a cost display 
  to the upgrade option and grey it out if the player doesnt have enough.
  
=end

#--------------------------------------------------------------------------
# * 
#--------------------------------------------------------------------------

class Window_Command
  def aps_cost_update
    s1 = $data_system.words.attack + ": " + Aps.upgrade_cost.to_s
    s2 = "Heal" + ": " + Aps.heal_cost.to_s
    s3 = $data_system.words.guard + ": " + Aps.uprate_cost.to_s
    s4 = "Nuke" + ": " + Aps.nuke_cost.to_s
    @commands = [s1, s2, s3, s4]
    aps_refresh
  end
  
  def aps_refresh
    self.contents.clear
    for i in 0...@item_max
      aps_draw_item(i, normal_color)
    end
  end
  
  def aps_draw_item(index, color)
    case index
    when 0
      if Aps.can_upgrade?
        self.contents.font.color = color
      else
        self.contents.font.color = disabled_color
      end
    when 1
      if Aps.can_heal?
        self.contents.font.color = color
      else
        self.contents.font.color = disabled_color
      end
    when 2
      if Aps.can_uprate?
        self.contents.font.color = color
      else
        self.contents.font.color = disabled_color
      end
    when 3
      if Aps.can_nuke?
        self.contents.font.color = color
      else
        self.contents.font.color = disabled_color
      end
    end
    rect = Rect.new(4, 32 * index, self.contents.width - 8, 32)
    self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
    self.contents.draw_text(rect, @commands[index])
  end
end