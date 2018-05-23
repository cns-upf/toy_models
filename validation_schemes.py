#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Mar 12 09:38:47 2018

@author: andrea

Toy model to show different validation schemes for ML estimators.
- k-fold
- repeated shuffle split
- nested CV
- stratified CV
- time series CV
- grouped samples CV
"""

import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.linear_model import LinearRegression, LogisticRegression
from sklearn.neighbors import KNeighborsClassifier
from sklearn.model_selection import ShuffleSplit, StratifiedShuffleSplit, KFold
from sklearn.datasets import make_classification
from sklearn.dummy import DummyClassifier

#%% Balanced classes
X, y = make_classification(n_samples=100, n_features=2, n_informative=2,
                           n_redundant=0, n_repeated=0, n_classes=2,
                           weights=[0.5, 0.5], n_clusters_per_class=1,
                           class_sep=0.4, random_state=8)
# plot data
fig, ax = plt.subplots(nrows=2, ncols=2)
ax[0, 0].scatter(X[y==0, 0], X[y==0, 1], marker='o', c='orange')
ax[0, 0].scatter(X[y==1, 0], X[y==1, 1], marker='s', c='green')
ax[1, 0].scatter(X[y==0, 0], X[y==0, 1], marker='o', c='orange')
ax[1, 0].scatter(X[y==1, 0], X[y==1, 1], marker='s', c='green')
ax[0, 0].set_title('complex')
ax[1, 0].set_title('simple')
ax[1, 0].set_xlabel('feature 1')
ax[1, 0].set_ylabel('feature 2')
ax[1, 1].remove()
# models
clf_complex = KNeighborsClassifier(n_neighbors=1)
clf_simple = KNeighborsClassifier(n_neighbors=10)
# show decision boundary for whole dataset
clf_complex.fit(X, y)
clf_simple.fit(X, y)
xfig = np.linspace(ax[0, 0].get_xlim()[0], ax[0, 0].get_xlim()[1], 100)
yfig = np.linspace(ax[0, 0].get_ylim()[0], ax[0, 0].get_ylim()[1], 100)
Xfig, Yfig = np.meshgrid(xfig, yfig)
Xpred = np.vstack((Xfig.flatten(), Yfig.flatten())).T
predC = clf_complex.predict(Xpred)
predS = clf_simple.predict(Xpred)
ax[0, 0].contour(Xfig, Yfig, np.reshape(predC, Xfig.shape))
ax[1, 0].contour(Xfig, Yfig, np.reshape(predS, Xfig.shape))
# cross-validation
repetitions = 100
shS = ShuffleSplit(n_splits=repetitions, test_size=0.2, random_state=0)
scoreC = np.zeros([repetitions])
scoreS = np.zeros([repetitions])
i = 0
for train_idx, test_idx in shS.split(X):
    data_train = X[train_idx, :]
    y_train = y[train_idx]
    data_test = X[test_idx, :]
    y_test = y[test_idx]
    clf_complex.fit(data_train, y_train)
    clf_simple.fit(data_train, y[train_idx])
    scoreC[i] = clf_complex.score(data_test, y_test)
    scoreS[i] = clf_simple.score(data_test, y[test_idx])
    i += 1

# plot comparison as violin plots
sns.violinplot(data=[scoreC, scoreS], cut=0, orient='h', scale='width', ax=ax[0, 1])
ax[0, 1].set_yticklabels(['complex', 'simple'])
ax[0, 1].set_xlabel('test-set accuracy')

#%% Unbalanced classes
X, y = make_classification(n_samples=500, n_features=25, n_informative=20,
                           n_redundant=5, n_repeated=0, n_classes=2,
                           weights=[0.2, 0.8], n_clusters_per_class=1,
                           class_sep=0.5, random_state=None)
yR = np.random.permutation(y)
clf = LogisticRegression(C=10000, penalty='l2', multi_class= 'multinomial', solver='lbfgs')
#clf = KNeighborsClassifier(n_neighbors=1)
clfR = LogisticRegression(C=10000, penalty='l2', multi_class= 'multinomial', solver='lbfgs')
#clfR = KNeighborsClassifier(n_neighbors=1)
clfD = DummyClassifier(strategy='most_frequent')
repetitions = 100
shS = ShuffleSplit(n_splits=repetitions, test_size=0.2, random_state=None)
score = np.zeros([repetitions])
scoreD = np.zeros([repetitions])
scoreR = np.zeros([repetitions])
i = 0
for train_idx, test_idx in shS.split(X):
    data_train = X[train_idx, :]
    y_train = y[train_idx]
    data_test = X[test_idx, :]
    y_test = y[test_idx]
    clf.fit(data_train, y_train)
    clfD.fit(data_train, y_train)
    clfR.fit(data_train, yR[train_idx])
    score[i] = clf.score(data_test, y_test)
    scoreD[i] = clfD.score(data_test, y_test)
    scoreR[i] = clfR.score(data_test, yR[test_idx])
    i += 1

# plot comparison as violin plots
fig, ax = plt.subplots(nrows=2, ncols=1, sharex=True)
sns.violinplot(data=[score, scoreD, scoreR], cut=0, orient='h', scale='width', ax=ax[0])
ax[0].set_yticklabels(['good', 'bad', 'random'])
ax[0].set_title('random permutations CV')

shS = StratifiedShuffleSplit(n_splits=repetitions, test_size=0.2, random_state=None)
score = np.zeros([repetitions])
scoreD = np.zeros([repetitions])
scoreR = np.zeros([repetitions])
i = 0
for train_idx, test_idx in shS.split(X, y):
    data_train = X[train_idx, :]
    y_train = y[train_idx]
    data_test = X[test_idx, :]
    y_test = y[test_idx]
    clf.fit(data_train, y_train)
    clfD.fit(data_train, y_train)
    score[i] = clf.score(data_test, y_test)
    scoreD[i] = clfD.score(data_test, y_test)
    i += 1
i = 0
for train_idx, test_idx in shS.split(X, yR):
    data_train = X[train_idx, :]
    y_train = y[train_idx]
    data_test = X[test_idx, :]
    y_test = y[test_idx]
    clfR.fit(data_train, yR[train_idx])
    scoreR[i] = clfR.score(data_test, yR[test_idx])
    i += 1

# plot comparison as violin plots
sns.violinplot(data=[score, scoreD, scoreR], cut=0, orient='h', scale='width', ax=ax[1])
ax[1].set_yticklabels(['good', 'bad', 'random'])
ax[1].set_title('stratified random permutations CV')
ax[1].set_xlabel('classification accuracy')
