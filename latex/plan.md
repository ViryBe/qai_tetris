# Tetris

##Introduction

---

## Tetris
### Le jeu et sa simplification

Tetris met le joueur au défi de réaliser des lignes complètes en déplaçant des pièces de formes différentes, les tétrominos, qui défilent depuis le haut jusqu'au bas de l'écran. Les lignes complétées disparaissent tout en rapportant des points et le joueur peut de nouveau remplir les cases libérées. Le jeu n'a pas de fin : le joueur perd la partie lorsqu'un tétrimino reste bloqué en haut.

Dans notre version simplifié, il n'y a pas de limite de hauteur, le jeu se termine après que je jeu ai donné 10000 tetrominos à placer. De plus notre tetris diffère par une grille plus étroite (6 colones disponibles), moins de tetrominos différents (seulement 5) et des tetrominos plus petit (taille inférieur à 2).

<center>
LISTE DES TETROMINOS
</center>

Pour placer le tetrominos le joueur peut choisir la colone et l'orientation de la pièce. Contrairement au tetris classique, les pièces ne défilent pas du haut de l'écran mais sont directement placé en jeu et l'on a plus d'emprise sur elle une fois l'action choisie.



### L'implémentation

#### Représenation

##### Le plateau (Board)

Le plateau a été initialement représenté par une matrice de dimension 20000 * 6 (2 * nombre tetromino) d'entiers compris entre 0 et 5, 0 emplacement vide.

##### Les tetrominos

Les tetrominos sont des pièces de dimension  2 * 2 implémenté par des tableaux 1 dimension de longueur 4.
Le choix de tableau  à 1 dimension est motivé par l'application de rotation sur les pièces (North, South, East et West). En effet on a trouvé une modélisation simple pour cette représentation permettant d'appliquer une rotation sans créer de nouvelle pièce.

<center>
passage 2 * 2 -> 1 * 4
</center>

Les tetrominos sont tous de même dimension par soucis d'homogeneite et et cela peut entrainer un probleme de "tetromino flottant". Ce probleme est traité par un choix d'action spécifique à chaque pièce (cf partie x).
