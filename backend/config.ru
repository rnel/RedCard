use Rack::Static,
  :urls => ["/js", "/css"],
  :root => "frontend"

run lambda { |env|
  [
    200,
    {
      'Content-Type'  => 'text/html',
      'Cache-Control' => 'public, max-age=86400'
    },
    File.open('frontend/index.html', File::RDONLY)
  ]
}
