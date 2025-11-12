<?php

use App\Http\Controllers\SearchController;
use Illuminate\Support\Facades\Route;
use Statamic\Exceptions\NotFoundHttpException;

// A redirect route for the default Statamic control panel.
if (config('statamic.cp.route') !== 'cp') {
    Route::get('/cp', fn () => to_route('statamic.cp.dashboard'));
}

Route::get('/search', [SearchController::class, 'index'])->name('search.index');

// Custom taxonomy routes

$map = [
    [
        'collection_handle' => 'products',
        'taxonomy_handle' => 'categories',
        'uri_slug' => 'category',
    ],
];
//
//foreach ($map as $route) {
//    $collection = \Statamic\Facades\Collection::findByHandle($route['collection_handle']);
//    if (!$collection) {
//        throw new NotFoundHttpException();
//    }
//
//    $routeWithTaxonomy = implode('/', array($route['collection_handle'], $route['uri_slug'], '{slug}'));
//    Route::statamic($routeWithTaxonomy, "products.$route[uri_slug].show");
//}
