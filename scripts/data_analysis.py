from sys import argv
from math import sqrt
import re

def average(l):
    return sum(l)/len(l)


def standard_deviation(l):
    """
    compute standard_deviation without bias
    """
    sum = 0
    m = average(l)
    for elt in l:
        sum += (elt - m) ** 2
    return sqrt(sum / (len(l) -1))


def compute_stats(dic_rslt, ntetro, ngames, th):
    rslt = {}
    # threshold_height = ntetro / 100  # 1% of the nb of tetro
    threshold_height = th

    threshold_means = int(ngames / 10)

    for key in dic_rslt:
        thresholds = []
        means = []
        standard_deviations = []

        for l in dic_rslt[key]:
            # index of th fist time under threshold_height
            for h in l:
                if h < threshold_height:
                    thresholds.append(l.index(h))
                    break

            # compte average and sqrt(standard_deviation) of last heights
            if len(l) > 1:
                means.append(average(l[-threshold_means:])) # last 1% heights
                standard_deviations.append(standard_deviation(l[-threshold_means:])) # last 1% heights

        if len(thresholds) > 0 and len(means) > 0:
            rslt[key] = [average(thresholds), average(means), average(standard_deviations)]

    return rslt


def best_params(dict_stat, feature="th"):
    """
    feature : 'mean' | 'var' | 'th'
    return the best (alpha, epsilon, gamma) for a given feature
    """
    param_max = ""
    min_mean, min_threashold, min_var = 10000, 10000, 10000
    for key in dict_stat:
        # we'ere interseted only in feature
        if (feature == 'th' and dict_stat[key][0] < min_threashold
            or feature == 'mean' and dict_stat[key][1] < min_mean
            or feature == 'var' and dict_stat[key][2] < min_var):
            param_max = key
            min_threashold, min_mean, min_var = dict_stat[key]

    return param_max, min_mean, min_threashold, min_var


def com_parser(filename):
    """
    renvoie le nombre de tetrominos et de parties à partir du fichier filename
    """
    with open(filename, "r") as f:
        ngames = 0
        ntetro = 0
        for line in f:
            if line[0] == "#":
                try:
                    ntetro = int(re.search(r"ntetro:(\d+)", line).group(1))
                except:
                    pass
                try:
                    ngames = int(re.search(r"ngames:(\d+)", line).group(1))
                except:
                    pass

    return ngames, ntetro

def content_parser(filename):
    """
    pase rslt file 'filename'
    ret dictionnary with format:
    key: str of params
    val= array of array of height
    """
    rslt = {}

    with open(filename, "r") as f:
        current_vals = []

        for line in f:
            if line[0] == '#': # do nothing for comments
                pass

            elif line[0] == 'a': # line with args
                if (line[:-1] not in rslt):
                    rslt[line[:-1]] = []

                rslt[line[:-1]].append(current_vals)  # -1 -> removes '\n'

                current_vals = []
            else: # store the height in the list
                current_vals.append(int(line))

    return rslt


def affichage_rslts(r1, r2, r3):

    print("                    |   {:<40} {:<10} {:<10} {:<10}".format("params", "mean", "s.d.", "th"))
    print("best mean           |   {:<40} {:.2f}   |   {:.2f}   |   {:.2f}".format(r1[0], r1[1], r1[3], r1[2]))
    print("best std deviation  |   {:<40} {:.2f}   |   {:.2f}   |   {:.2f}".format(r3[0], r3[1], r3[3], r3[2]))
    print("best threashold     |   {:<40} {:.2f}   |   {:.2f}   |   {:.2f}".format(r2[0], r2[1], r2[3], r2[2]))


if __name__ == '__main__':
    """
    il faut un param -> le nom du fichier a analyser
    """
    filename = argv[1]
    ngames, ntetro = com_parser(filename)
    dic_parsed = content_parser(filename)

    print("alpha   = [0.0001 0.0005 0.0007 0.0010 0.0012 0.0015 0.0020 0.0050 0.0100]")
    print("epsilon = [0.0005 0.0010 0.0015 0.0020 0.0025 0.0100 0.0200 0.1000 0.1500]")
    print("gamma   = [0.5500 0.6000 0.6500 0.7000 0.7500 0.8000 0.8500 0.9000 0.9500 1.0000]")

    th = 100
    print("threashold = {}".format(th))

    dict_stat = compute_stats(dic_parsed, ntetro, ngames, th)
    r1 = best_params(dict_stat, 'mean')
    r2 = best_params(dict_stat, 'th')
    r3 = best_params(dict_stat, 'var')
    affichage_rslts(r1, r2, r3)
