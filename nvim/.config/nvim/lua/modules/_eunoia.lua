local lush = require("lush")

return lush(function()
  local dark = "#171c26"
  local white = "#F3F2F7"

  return {
    Normal { bg = dark, fg = white }
  }
end)
