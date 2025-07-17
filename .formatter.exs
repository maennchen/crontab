[
  inputs: [
    "{mix,.formatter}.exs",
    "{lib,test,config}/**/*.{ex,exs}"
  ],
  plugins: [Styler, DoctestFormatter],
  styler: [
    minimum_supported_elixir_version: "1.15.0"
  ]
]
