<?php

use Illuminate\Support\Facades\Route;

// A redirect route for the default Statamic control panel.
if (config('statamic.cp.route') !== 'cp') {
    Route::get('/cp', fn () => to_route('statamic.cp.dashboard'));
}
