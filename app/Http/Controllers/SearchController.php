<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Statamic\View\View;

class SearchController extends Controller
{
    public function index(Request $request)
    {
        return (new View)
            ->template('search')
            ->layout('layout')
            ->with([]);
    }
}
