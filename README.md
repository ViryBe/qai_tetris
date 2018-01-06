# Tetris par Q learning

## Building

* build all : ```$ make```
* build documentation (output HTML) : ```$ make doc```
* build tags ([ctags](http://ctags.sourceforge.net/)) : ```$ make tags```
* clean : ```$ make clean```

### Exécutables résultants


* ```tetris_player``` (compilé avec ```ocamlc```)
* ```tetris_player.opt``` (compilé avec ```ocamlopt```)
* ```tetris_player.top``` : top-level avec import de tout les modules


## Entrainement Agent
```bash
$ ./tetris_player -ngames 500 -ntetr 10000 -gamma 0.8 -epsilon 0.05 -alphap 0.005 -qsave qmat.save
```
ou
```bash
$ ./tetris_player.opt -ngames 500 -ntetr 10000 -gamma 0.8 -epsilon 0.05 -alphap 0.005 -qsave qmat.save
```

#### Performances
Pour un entrainement de 500 parties de 10k tetrominos:

* ```./tetris_player``` ~ 2 minutes
* ```./tetris_player.opt``` ~ 15 secondes

## Visualisation d'un jeu

A partir d'une matrice 'qmat.save':

```$ ./tetris_player -demo -qload qmat.save```

## Script ```tetris_parameval.bash```

Permet l'affichage de graphes donnant la hauteur de chaque partie en fonction
du nombre de jeux, en faisant varier un paramètre donné (ex gamma, epsilon ou
alpha).

Exemple pour une variation 10 valeurs de gamma dans 0, 1:

```$ ./tetris_parameval.bash --param gamma --low 0 --up 1 --nval 10```

* ```--param``` : paramètre à faire varier
* ```--low``` : borne inférieure de variation
* ```--up``` : borne superieure de variation
* ```--nval```  : nombre de valeurs à prendre dans l'interval [low, up]


Calcule également les parametres optimaux avec l'option ```--panacea```:

```$ ./tetris_parameval.bash --panacea --ngames 512 --ntetr 10000```


## Dépendances

* ```gnuplot```
* Modules OCaml : ```Marshal```, ```Graphics``` et ```Unix```


## Documentation additionnelle

```$ ./tetris_player --help```

```$ ./tetris_parameval.bash --help```
