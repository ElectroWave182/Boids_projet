class_name Jeu
extends Node2D


const tempsMax: float = 20
const hauteur: int = 1080
const largeur: int = 1920
const modele: PackedScene = preload ("res://scenes/Element.tscn")
const nomLieu:   String = "stand_de_tir"
const nomMeneur: String = "meneur"
const nomSbire:  String = "sbire_"
const nomViseur: String = "viseur"
const positionTete = Vector2 (0, -108)

static var debut = true;
static var rng = RandomNumberGenerator. new ()
var boids: Array = []
var boidMeneur: Boid
var enCours: bool
var tempsEcoule: float
var selection: Sprite2D = null
var viseur:    Sprite2D


func _ready () -> void:
	
	self. viseur = get_node (nomLieu + "/" + nomViseur)
	self. reinitialiser ()


func _process (delta: float) -> void:
	
	# Le jeu commence
	if (debut):
		return
	else:
		get_node (nomLieu). modulate = Couleur. blanc
	
	# Une unité de temps s'écoule
	self. tempsEcoule += delta
	self. deplacerBoids ()
	self. deplacerGens ()
	
	# Le joueur peut cliquer en cours de jeu
	if (self. enCours):
		self. gererEntrees ()
	
	# Le temps s'est écoulé entièrement
	if (self. tempsEcoule > tempsMax):
		self. finir (Couleur. rouge)


"Gère les évènements liés aux clics souris du joueur"

func gererEntrees () -> void:
	
	# Clic droit
	
	if (Input. is_action_pressed ("Selection")):
		
		self. selectionner ()
	
	
	# Clic gauche
	
	if (Input. is_action_pressed ("Validation") and self. selection != null):
		
		# La partie est gagnée
		if (self. selection == get_node (nomLieu + "/" + nomMeneur)):
			self. finir (Couleur. vert)
		
		# La partie est perdue
		else:
			self. finir (Couleur. rouge)


"Indique au joueur qu'il a gagné ou perdu, et réinitialise la partie"

func finir (resultat: Color) -> void:
	
	self. enCours = false
	
	# On met le meneur en vert ou en rouge
	get_node (nomLieu + "/" + nomMeneur). self_modulate = resultat
	
	# On réinitialise la partie après 1 seconde
	await get_tree (). create_timer (1). timeout
	self. reinitialiser ()


"Remet à 0 les noeuds et attributs suite à une nouvelle partie"

func reinitialiser () -> void:
	
	# Faisons le vide
	self. tempsEcoule = 0
	self. viseur. reparent (get_node (nomLieu))
	get_node (nomLieu + "/" + nomMeneur). free ()
	
	
	# Initialisation des boids à des positions aléatoires
	
	var x: int
	var y: int
	self. boids. clear ()
	
	# Pour le meneur
	x = rng. randi_range (0, largeur)
	y = rng. randi_range (0, hauteur)
	self. boidMeneur = Boid. new (x, y)
	
	# Pour les sbires
	for _i in range (Boid. nbBoids):
		x = rng. randi_range (0, largeur)
		y = rng. randi_range (0, hauteur)
		self. boids. append (Boid. new (x, y))
	
	
	# Réinitialisation des images
	
	# Nous masquons le viseur
	self. viseur. visible = false
	
	# L'on recrée le meneur
	var meneur: Node2D = modele. instantiate ()
	meneur. name = nomMeneur
	get_node (nomLieu). add_child (meneur)
	
	# Et les sbires
	var sbire: Sprite2D
	for id in range (Boid. nbBoids):
		sbire = modele. instantiate ()
		sbire. name = nomSbire + str (id)
		meneur. add_child (sbire)
	
	
	self. enCours = true


"Sélectionne un sbire sur lequel le pointeur souris se trouve"

func selectionner () -> void:
	
	# Sélection du meneur
	var meneur: Sprite2D = get_node (nomLieu + "/" + nomMeneur)
	if (meneur. estDedans ()):
		selectionnerImage (meneur)
		return
	
	# Récupération des sbires
	var sbire: Sprite2D
	for indice: int in range (Boid. nbBoids):
		sbire = get_node \
		( \
			nomLieu \
			+ "/" \
			+ nomMeneur \
			+ "/" \
			+ nomSbire \
			+ str (indice) \
		)
		
		# On choisit le premier sbire visé
		if (sbire. estDedans ()):
			selectionnerImage (sbire)
			return


"Sélectionne une image donnée"

func selectionnerImage (image: Node2D) -> void:
	
	# On met le viseur dessus
	self. viseur. reparent (image)
	self. viseur. visible = true
	
	# Et on stocke l'image en attribut
	self. selection = image


"Met à jour les coordonnées des boids suivant leur comportement"

func deplacerBoids () -> void:

	var distanceAutre: float
	for boid: Boid in self. boids:
	
	
		# Conservation des boids qui sont dans le champ de vision
		
		var boidsProches: Array = []
		for boidAutre: Boid in self. boids:
			if boidAutre == boid: continue
			
			# On a trouvé un boid proche
			distanceAutre = boid. distance (boidAutre)
			if distanceAutre < Boid. rayonVision:
				boidsProches. append (boidAutre)
		
		
		# Calcul des vitesses de déplacement
		
		boid. attrouper (boidsProches)
		boid. migrer    (boidsProches)
		boid. oxygener  (boidsProches)
		
		if (boidsProches == []):
			boid. errer ()
		
		ralentirBords (boid)
		
		# La vitesse du boid prend effet sur sa position
		boid. bouger ()
	
	
	# Coordonnées du meneur
	
	self. boidMeneur. errer ()
	ralentirBords (self. boidMeneur)
	self. boidMeneur. bouger ()


"Fait ralentir le boid s'il s'apprête à sortir de l'écran"

static func ralentirBords (boid: Boid) -> void:
	
	# Bord gauche
	if boid. x < Boid. marge \
	and boid. vitesseX < 0:
		boid. vitesseX += rng. randf ()
	
	# Bord droit
	if boid. x > largeur - Boid. marge \
	and boid. vitesseX > 0:
		boid. vitesseX -= rng. randf ()
	
	# Bord haut
	if boid. y < Boid. marge \
	and boid. vitesseY < 0:
		boid. vitesseY += rng. randf ()
	
	# Bord bas
	if boid. y > hauteur - Boid. marge \
	and boid. vitesseY > 0:
		boid. vitesseY -= rng. randf ()


"Met à jour la position des gens aux coordonnées stockées dans les boids"

func deplacerGens () -> void:
	
	# Affectation de la position du boid à celle du meneur
	get_node (nomLieu + "/" + nomMeneur). position = Vector2 (self. boidMeneur. x, self. boidMeneur. y)
	
	# Récupération des sbires
	var boid: Boid
	var cible: Node2D
	var sbire: Sprite2D
	for indice: int in range (Boid. nbBoids):
		boid = boids [indice]
		sbire = get_node \
		( \
			nomLieu \
			+ "/" \
			+ nomMeneur \
			+ "/" \
			+ nomSbire \
			+ str (indice) \
		)
		
		# Affectation de la position du boid à celle du sbire
		sbire. global_position = Vector2 (boid. x, boid. y)
	
	# Même chose pour le viseur sur la tête
	cible = self. viseur. get_parent ()
	self. viseur. global_position = cible. global_position + positionTete
