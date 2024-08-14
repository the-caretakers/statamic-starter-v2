<?php

return [
    'service' => env('CAPTCHA_SERVICE', 'Turnstile'), // options: Recaptcha / Hcaptcha / Turnstile
    'enabled' => env('CAPTCHA_ENABLED', false),
    'sitekey' => env('CAPTCHA_SITEKEY', ''),
    'secret' => env('CAPTCHA_SECRET', ''),
    'collections' => [],
    'forms' => env('CAPTCHA_ENABLED') ? 'all' : [],
    'user_login' => false,
    'user_registration' => false,
    'disclaimer' => '',
    'invisible' => false,
    'hide_badge' => false,
    'enable_api_routes' => false,
];
