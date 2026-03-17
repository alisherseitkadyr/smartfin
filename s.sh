#!/bin/bash

# Base path (change if needed)
BASE="lib/features"

# HOME FEATURE
mkdir -p $BASE/home/domain/entities
mkdir -p $BASE/home/domain/repositories
mkdir -p $BASE/home/domain/usecases

mkdir -p $BASE/home/data/models
mkdir -p $BASE/home/data/datasources
mkdir -p $BASE/home/data/repositories

mkdir -p $BASE/home/presentation/providers
mkdir -p $BASE/home/presentation/pages
mkdir -p $BASE/home/presentation/widgets

touch $BASE/home/domain/entities/home_entities.dart
touch $BASE/home/domain/repositories/home_repository.dart
touch $BASE/home/domain/usecases/home_usecases.dart

touch $BASE/home/data/models/home_models.dart
touch $BASE/home/data/datasources/home_local_datasource.dart
touch $BASE/home/data/repositories/home_repository_impl.dart

touch $BASE/home/presentation/providers/home_providers.dart
touch $BASE/home/presentation/pages/home_page.dart
touch $BASE/home/presentation/widgets/home_widgets.dart


# EXPENSES FEATURE
mkdir -p $BASE/expenses/domain/entities
mkdir -p $BASE/expenses/domain/repositories
mkdir -p $BASE/expenses/domain/usecases

mkdir -p $BASE/expenses/data/models
mkdir -p $BASE/expenses/data/datasources
mkdir -p $BASE/expenses/data/repositories

mkdir -p $BASE/expenses/presentation/providers
mkdir -p $BASE/expenses/presentation/pages
mkdir -p $BASE/expenses/presentation/widgets

touch $BASE/expenses/domain/entities/expense_entities.dart
touch $BASE/expenses/domain/repositories/expense_repository.dart
touch $BASE/expenses/domain/usecases/expense_usecases.dart

touch $BASE/expenses/data/models/expense_models.dart
touch $BASE/expenses/data/datasources/expense_local_datasource.dart
touch $BASE/expenses/data/repositories/expense_repository_impl.dart

touch $BASE/expenses/presentation/providers/expense_providers.dart
touch $BASE/expenses/presentation/pages/expense_page.dart
touch $BASE/expenses/presentation/widgets/expense_widgets.dart


echo "✅ Structure created successfully!"