addEventHandler("onPlayerJoin", root,
	function( )
		setTimer(function(source)
			showChat(source, false)
		end, 500, 1, source)
	end
)