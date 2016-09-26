## WORDPRESS CLEAN DB

# Modifications éventuelles :
# Nettoyer des transients ?

# Préfixe des tables
echo "Indiquez le préfixe des tables (avec le _ si nécéssaire) :"
read dbprefix

echo "Indiquez la date limite pour la suppression des éléments (saisissez la date au format AAAA-MM-DD ou 0 pour tout nettoyer) :"
read dbdate

# Liste des tables à nettoyer
dbt_posts=$dbprefix"posts"
dbt_term_relationships=$dbprefix"term_relationships"
dbt_postmeta=$dbprefix"postmeta"
dbt_options=$dbprefix"options"
dbt_comments=$dbprefix"comments"

if [[ $dbdate = "0" ]]
then
	# Suppression des révisions
	echo "Suppression des révisions..."
	wp db query "DELETE a,b,c FROM $dbt_posts a LEFT JOIN $dbt_term_relationships b ON (a.ID = b.object_id) LEFT JOIN $dbt_postmeta c ON (a.ID = c.post_id) WHERE a.post_type = 'revision';"
	echo "DONE"

	# Suppression des auto-drafts
	echo "Suppression des auto-drafts (sauvegardes automatiques)..."
	wp db query "DELETE FROM $dbt_posts WHERE post_status = 'auto-draft';"
	echo "DONE"
else
	# Suppression des révisions
	echo "Suppression des révisions antérieures au $dbdate..."
	wp db query "DELETE a,b,c FROM $dbt_posts a LEFT JOIN $dbt_term_relationships b ON (a.ID = b.object_id) LEFT JOIN $dbt_postmeta c ON (a.ID = c.post_id) WHERE a.post_type = 'revision' AND a.post_date < $dbdate;"
	echo "DONE"

	# Suppression des auto-drafts
	echo "Suppression des auto-drafts antérieurs au $dbdate..."
	wp db query "DELETE FROM $dbt_posts WHERE post_status = 'auto-draft' AND post_date < $dbdate;"
	echo "DONE"
fi

# Suppression des métas d'articles supprimés
echo "Suppression des métas d'articles supprimés..."
wp db query "DELETE pm FROM $dbt_postmeta pm LEFT JOIN $dbt_posts wp ON wp.ID = pm.post_id WHERE wp.ID IS NULL;"
echo "DONE"

# Suppression du cache des flux
echo "Suppression du cache des flux..."
wp db query "DELETE FROM $dbt_options WHERE option_name LIKE ('_transient%_feed_%');"
echo "DONE"

# Suppression du cache des commentaires de type spam
echo "Suppression des commentaires de type spam..."
wp db query "DELETE FROM $dbt_comments WHERE comment_approved = 'spam';"
echo "DONE"

# Optimisation de la base
wp db optimize