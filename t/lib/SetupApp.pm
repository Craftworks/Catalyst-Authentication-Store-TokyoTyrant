
$Servers = [
    { 'host' => 'localhost', 'port' => 1978 },
    { 'host' => 'localhost', 'port' => 1979 },
    { 'host' => 'localhost', 'port' => 1980 },
];

$ENV{'TESTAPP_CONFIG'} = {
    'name' => 'TestApp',
    'authentication' => {
        'default_realm' => 'users',
        'realms' => {
            'users' => {
                'credential' => {
                    'class' => 'Password',
                    'password_field'    => 'password',
                    'password_type'     => 'clear',
                },
                'store'         => {
                    'class'         => 'TokyoTyrant',
                    'servers'       => $Servers,
                    'user_key'      => 'id',
                    'user_name'     => 'name',
                    'role_key'      => 'role',
                },
            },
        },
    },
};

1;
