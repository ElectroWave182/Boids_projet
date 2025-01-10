class_name Boid
extends Node2D


const impactAttroupement: float = 0.001
const impactMigration:    float = 0.00001
const impactOxygenation:  float = 0.003
const rayonRepulsion:     float = 100
const rayonVision:        float = 130
const vitesseMax:         float = 3
const marge:   int = 100
const nbBoids: int = 20

static var rng = RandomNumberGenerator. new ()
var vitesseX: float
var vitesseY: float
var x: float
var y: float


"Constructeur : coordonnées et vitesse"

func _init (departX: float, departY: float):
	
	self. x = min (max (departX, 0), Jeu. largeur)
	self. y = min (max (departY, 0), Jeu. hauteur)
	
	self. vitesseX = vitesseBase () / 2.
	self. vitesseY = vitesseBase () / 2.


"Retourne un nombre aléatoire qui sert de base pour la vitesse"

static func vitesseBase () -> float:
	
	return rng. randi_range (-5, 5)


"Renvoie la distance euclidienne du boid à un autre"

func distance (boid: Boid) -> float:
	
	var distX: float = self. x - boid. x
	var distY: float = self. y - boid. y
	
	return sqrt (distX ** 2 + distY ** 2)


"Se déplace vers un groupe de boids"

func attrouper (boids: Array) -> void:
	
	# Enlève le cas d'erreur "boids == []"
	if len (boids) < 1: return
	
	
	# Calcule la position moyenne relative du groupe de boids
	
	var moyenneX: float = 0
	var moyenneY: float = 0
	
	# Somme
	for boid: Boid in boids:
		moyenneX += (self. x - boid. x)
		moyenneY += (self. y - boid. y)
	
	# Pondération
	moyenneX /= len (boids)
	moyenneY /= len (boids)
	
	
	# Applique les changements de vitesse
	self. vitesseX -= (moyenneX * impactAttroupement)
	self. vitesseY -= (moyenneY * impactAttroupement)


"Se déplace dans la même direction qu'un groupe de boids"

func migrer (boids: Array) -> void:
	
	# Enlève le cas d'erreur "boids == []"
	if len (boids) < 1: return
	
	
	# Calcule la position moyenne relative du groupe de boids
	
	var moyenneX: float = 0
	var moyenneY: float = 0
	
	# Somme
	for boid: Boid in boids:
		moyenneX += boid. vitesseX
		moyenneY += boid. vitesseY
	
	# Pondération
	moyenneX /= len (boids)
	moyenneY /= len (boids)
	
	
	# Applique les changements de vitesse
	self. vitesseX += (moyenneX * impactMigration)
	self. vitesseY += (moyenneY * impactMigration)


"S'écarte d'un groupe de boids"

func oxygener (boids: Array) -> void:
	
	# Enlève le cas d'erreur "boids == []"
	if len (boids) < 1: return
	
	# Calcul de la racine carrée à l'avance
	const racineRayon: float = sqrt (rayonRepulsion)
	
	var distanceAutre: float
	var distX: float
	var distY: float
	var sommeX: float = 0
	var sommeY: float = 0
	
	
	# Calcul de la position totale relative du groupe de boids proches
	
	for boid: Boid in boids:
		
		# Si le boid est dans le disque de répulsion,
		distanceAutre = self. distance (boid)
		if (distanceAutre < rayonRepulsion):
			
			# On calcule sa distance à la racine du cercle
			distX = boid. x - self. x
			distY = boid. y - self. y
			if (distX != 0.):
				distX -= racineRayon / abs (distX)
			if (distY != 0.):
				distY -= racineRayon / abs (distY)
			
			# Et l'on en fait la somme
			sommeX += distX 
			sommeY += distY 
	
	
	# Applique les changements de vitesse
	self. vitesseX -= sommeX * impactOxygenation
	self. vitesseY -= sommeY * impactOxygenation


"Erre si aucun boid n'est vu"

func errer () -> void:
	
	# Applique des changements de vitesse aléatoires
	self. vitesseX += vitesseBase () / 30.
	self. vitesseY += vitesseBase () / 30.


"Fait s'écouler une unité de temps en appliquant la vitesse sur la position"

func bouger ():
	
	# Réduit la vitesse si elle est considérée comme trop élevée
	
	if abs (self. vitesseX) > vitesseMax \
	or abs (self. vitesseY) > vitesseMax:
		
		var coefReduction: float = vitesseMax / max (abs (self. vitesseX), abs (self. vitesseY))
		
		self. vitesseX *= coefReduction
		self. vitesseY *= coefReduction
	
	
	# Applique la vitesse
	self. x += self. vitesseX
	self. y += self. vitesseY
