%Angeline Lafleur
%Minesweeper
%Version 1.11
%21 novembre 2018

%Declare les variables globales
var pic : int := Pic.FileNew ("unclickedspace.jpg")
var width : int := Pic.Width (pic)
var height : int := Pic.Height (pic)
var x, y : int := 0
var gridh, gridl : int := 12
var coinx, coiny : int := 8
var state : array 1 .. gridl, 1 .. gridh of string (1)
var statevisible : array 1 .. gridl, 1 .. gridh of string (1)
var nmine : int
var mousex, mousey, mouseb, left, middle, right : int
var ch, caresult : string (1)
var valide, valide2, first : boolean
var font := Font.New ("Times:11")

%Affcihe les instructions
color (blue)
put "Bienvenue au jeu de " ..
color (red)
put "Minesweeper!"
color (green)
put "Voici les instructions du jeu:"
color (black)
put "1. Cliquez avec le bouton gauche de la souris sur une case pour révéler un espace caché."
put "2. Cliquez avec le bouton droit de la souris sur une case pour y placer ou enlever un drapeau."
put
    "3. Un nombre révélé vous indique EXACTEMENT le nombre de mines à proximité (Haut, Bas, Gauche, Droite et toutes les diagonales). Utilisez cette logique pour déterminer où se trouvent les mines et les éviter!"
put
    "4. Un espace révélé vide signifie qu'il n'y a pas de mines dans les environs immédiats. Toutes les cases vides révéleront les carrés adjacents."
put "5. Utiliser un drapeau vous permettra d'éviter l'endroit où vous pensez qu'une mine est placée." ..
put
    "Cela vous évitera également de révéler accidentellement cet espace spécifique de la grille. Si vous décidez de changer d'avis, supprimez simplement le drapeau en cliquant encore dessus avec le bouton droit de la souris."
put "6. La partie est gagnée lorsque tous les espaces contenant aucune mine sont révélés."
put "7. Vous perdez la partie si vous révélez une mine."
put ""
color (green)
put "Appuyez n'importe quelle touche pour continuer..."
getch (ch)

%Declare la procedure qui assigne une noumbre (de mines autour) a un carre revele. source: voir "\Minesweeper-master\Files\Code\GameInput.t"
procedure checkadjacent
    var counter : int := 0
    var tempa : int := 0
    var tempi : int := 0
    for a : 1 .. 3
	tempa := x - 2 + a
	for i : 1 .. 3
	    tempi := y - 2 + i
	    if tempi >= 1 and tempi <= gridh and tempa >= 1 and tempa <= gridl
		    then
		if state (tempa, tempi) = "m"
			then
		    counter += 1
		end if
	    end if
	end for
    end for
    if counter = 0 then
	caresult := "b"
    else
	caresult := intstr (counter)
    end if
end checkadjacent

%procedure qui revele plusieurs carres si vides
procedure reveal
    var tempa : int := 0
    var tempi : int := 0
    for a : 1 .. 3
	tempa := x - 2 + a
	for i : 1 .. 3
	    tempi := y - 2 + i
	    if tempi >= 1 and tempi <= gridh and tempa >= 1 and tempa <= gridl and (statevisible (tempa, tempi) = "u" or statevisible (tempa, tempi) = "f")
		    then
		if state (tempa, tempi) = "b"
			then
		    Pic.ScreenLoad ("revealed space.jpg", (tempa - 1) * width + 8, (tempi - 1) * height + 8, picCopy)
		    statevisible (tempa, tempi) := "d"
		else
		    statevisible (tempa, tempi) := "r"
		    Pic.ScreenLoad (state (tempa, tempi) + ".jpg", (tempa - 1) * width + 8, (tempi - 1) * height + 8, picCopy)
		end if
	    end if
	end for
    end for
end reveal

%process de son d'explosion
process son
    Music.PlayFile ("ExplosionFX.mp3")
end son

%procedure qui revele tout l,ecran apres qu'une mine est cliquee
procedure gameover
    put "Tu as perdu."
    fork son
    for i : 1 .. gridh
	for a : 1 .. gridl
	    if state (a, i) = "b" then
		Pic.ScreenLoad ("revealed space.jpg", coinx, coiny, picCopy)
	    elsif state (a, i) = "m" then
		Pic.ScreenLoad ("clickedmine.jpg", coinx, coiny, picCopy)
	    else
		Pic.ScreenLoad (state (a, i) + ".jpg", coinx, coiny, picCopy)
	    end if
	    coinx += width
	end for
	coinx := 8
	coiny += height
    end for
end gameover

%procedure qui cree la 'board' et qui fait l'action correspondante quand un carre est clique
procedure main
    cls
    for i : 1 .. gridh
	for a : 1 .. gridl
	    statevisible (a, i) := "u"
	    Pic.ScreenLoad ("unclickedspace.jpg", coinx, coiny, picCopy)
	    coinx += width
	end for
	coinx := 8
	coiny += height
    end for

    if gridh = 8 then
	nmine := 10
    elsif gridh = 10 then
	nmine := 12
    else
	nmine := 20
    end if

    for i : 1 .. gridh
	for a : 1 .. gridl
	    state (a, i) := "b"
	end for
    end for

    for i : 1 .. nmine
	var tempx : int := Rand.Int (1, gridh)
	var tempy : int := Rand.Int (1, gridl)
	loop
	    if state (tempx, tempy) = "m" then
		tempx := Rand.Int (1, gridh)
		tempy := Rand.Int (1, gridl)
	    else
		state (tempx, tempy) := "m"
		exit
	    end if
	end loop
    end for

    for i : 1 .. gridh
	for a : 1 .. gridl
	    if state (a, i) = "b"
		    then
		x := a
		y := i
		checkadjacent
		state (a, i) := caresult
	    end if
	end for
    end for

    coinx := 8
    coiny := 8
    first := true
    buttonchoose ("multibutton")
    loop
	var counter : int := 0
	for i : 1 .. gridh
	    for a : 1 .. gridl
		if state (a, i) not= "m" and (statevisible (a, i) = "r" or statevisible (a, i) = "f") then
		    counter += 1
		end if
	    end for
	end for
	if counter = gridh * gridl - nmine then
	    put "Bravo, tu as gagné!!!"
	    exit
	end if
	mousewhere (mousex, mousey, mouseb)
	left := mouseb mod 10
	middle := (mouseb - left) mod 100
	right := mouseb - middle - left

	if mousex <= coinx + gridl * width and mousex >= coinx and mousey <= coiny + gridh * height and mousey >= coiny and left = 1 then
	    var a, i : int
	    a := (mousex - 8) div width + 1
	    i := (mousey - 8) div height + 1
	    statevisible (a, i) := "r"
	    if state (a, i) = "b" then
		x := a
		y := i
		Pic.ScreenLoad ("revealed space.jpg", (a - 1) * width + 8, (i - 1) * height + 8, picCopy)
		statevisible (a, i) := "r"
		reveal
		for t : 1 .. 10
		    for j : 1 .. gridh
			for b : 1 .. gridl
			    if statevisible (b, j) = "d" then
				x := b
				y := j
				Pic.ScreenLoad ("revealed space.jpg", (b - 1) * width + 8, (j - 1) * height + 8, picCopy)
				statevisible (b, j) := "r"
				reveal
			    end if
			end for
		    end for
		end for
	    elsif state (a, i) = "m" then
		if first = true then
		    main
		else
		    gameover
		end if
		exit
	    else
		Pic.ScreenLoad (state (a, i) + ".jpg", (a - 1) * width + 8, (i - 1) * height + 8, picCopy)
	    end if
	    first := false
	end if

	if mousex <= coinx + gridl * width and mousex >= coinx and mousey <= coiny + gridh * height and mousey >= coiny and right = 100 then
	    var a, i : int
	    a := (mousex - 8) div width + 1
	    i := (mousey - 8) div height + 1
	    if statevisible (a, i) = "u" then
		statevisible (a, i) := "f"
		Pic.ScreenLoad ("flag.jpg", (a - 1) * width + 8, (i - 1) * height + 8, picCopy)
	    elsif statevisible (a, i) = "f" then
		statevisible (a, i) := "u"
		Pic.ScreenLoad ("unclickedspace.jpg", (a - 1) * width + 8, (i - 1) * height + 8, picCopy)
	    end if
	end if
	delay (100)
    end loop
end main

%affiche le menu principal, permet de choisir un niveau, et permet de rejouer ou d'aller au menu a la fin d'une joute
loop
    cls
    color (black)
    Font.Draw ("Menu principal", 275, 350, font, black)
    drawfillbox (200, 250, 440, 300, purple)
    Font.Draw ("Facile 8 x 8", 285, 270, font, white)
    drawfillbox (200, 175, 440, 225, purple)
    Font.Draw ("Moyen 10 x 10", 280, 195, font, white)
    drawfillbox (200, 100, 440, 150, purple)
    Font.Draw ("Difficile 12 x 12", 275, 120, font, white)
    valide := false
    coinx := 8
    coiny := 8
    loop
	exit when valide = true
	mousewhere (mousex, mousey, mouseb)
	if 200 <= mousex and mousex <= 440 and 250 <= mousey and mousey <= 300 and mouseb = 1 then
	    gridh := 8
	    gridl := 8
	    delay (100)
	    main
	    valide := true
	elsif 200 <= mousex and mousex <= 440 and 175 <= mousey and mousey <= 225 and mouseb = 1 then
	    gridh := 10
	    gridl := 10
	    delay (100)
	    main
	    valide := true
	elsif 200 <= mousex and mousex <= 440 and 100 <= mousey and mousey <= 150 and mouseb = 1 then
	    gridh := 12
	    gridl := 12
	    delay (100)
	    main
	    valide := true
	else
	    valide := false
	end if
    end loop
    valide2 := false
    loop
	exit when valide2 = true
	drawfillbox (450, 25, 600, 75, red)
	Font.Draw ("Menu principal", 480, 45, font, white)
	drawfillbox (450, 85, 600, 135, red)
	Font.Draw ("Rejouer", 500, 105, font, white)
	valide := false
	loop
	    exit when valide = true
	    mousewhere (mousex, mousey, mouseb)
	    if 450 <= mousex and mousex <= 600 and 25 <= mousey and mousey <= 75 and mouseb = 1 then
		valide2 := true
		valide := true
	    elsif 450 <= mousex and mousex <= 600 and 85 <= mousey and mousey <= 135 and mouseb = 1 then
		coinx := 8
		coiny := 8
		main
		valide := true
	    end if
	end loop
    end loop
end loop

