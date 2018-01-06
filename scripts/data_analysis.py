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


def compute_stats(dic_rslt, ntetro, ngames):
    rslt = {}
    threshold_height = ntetro / 100  # 1% of the nb of tetro
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


if __name__ == '__main__':
    filename = argv[1]
    # ntetro = com_parser(filename)
    ngames, ntetro = com_parser(filename)
    dic_parsed = content_parser(filename)
    dict_stat = compute_stats(dic_parsed, ntetro, ngames)
    print("mean\tthreshold\tstandard deviation")
    print("best mean")
    print(best_params(dict_stat, 'mean'))
    print("best threashold")
    print(best_params(dict_stat, 'th'))
    print("best standard_deviation")
    print(best_params(dict_stat, 'var'))
