# Tetris par Q learning

## Building

* build all : ```$ make```
* build documentation (output HTML) : ```$ make doc```
* build tags ([ctags](http://ctags.sourceforge.net/)) : ```$ make tags```
* clean : ```$ make clean```

### Exécutables résultants


* ```main.byte``` (compilé avec ```ocamlc```)
* ```main.native``` (compilé avec ```ocamlopt```)


## Entrainement Agent
```bash
$ ./main.byte -ngames 500 -ntetr 10000 -gamma 0.8 -epsilon 0.05 -alphap 0.005 -qsave save.qmat
```
ou
```bash
$ ./main.native -ngames 500 -ntetr 10000 -gamma 0.8 -epsilon 0.05 -alphap 0.005 -qsave save.qmat
```

#### Performances
Pour un entrainement de 500 parties de 10k tetrominos:

* ```./main.byte``` ~ 2 minutes
* ```./main.native``` ~ 15 secondes

## Visualisation d'un jeu

A partir d'une matrice 'qmat.save':

```$ ./main.native -demo -qload save.qmat```

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

Ce script entraîne un agent pour ~800 triplets de paramètres différents.
Il est donc (très) long à exectuer (+3h30 sur Intel Core i7...).

## Dépendances

* ```gnuplot```
* Modules OCaml : ```ocamlbuild```, ```Marshal```, ```Graphics``` et ```Unix```


## Documentation additionnelle

```$ ./main.native --help```

```$ ./tetris_parameval.bash --help```
