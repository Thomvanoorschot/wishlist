{application,tails,
    [{config_mtime,1732977642},
     {compile_env,
         [{tails,[color_classes],error},
          {tails,
              [colors_file],
              {ok,<<"/Users/thomvanoorschot/Development/wishlist/assets/tailwind.colors.json">>}},
          {tails,[dark_themes],error},
          {tails,[fallback_to_colors],error},
          {tails,[no_merge_classes],error},
          {tails,[themes],error},
          {tails,[variants],error}]},
     {optional_applications,[]},
     {applications,[kernel,stdlib,elixir,logger,jason]},
     {description,"tails"},
     {modules,
         ['Elixir.Inspect.Tails','Elixir.String.Chars.Tails','Elixir.Tails',
          'Elixir.Tails.ColorClasses','Elixir.Tails.Colors',
          'Elixir.Tails.Custom','Elixir.Tails.Directions','Elixir.Tails.Doc']},
     {registered,[]},
     {vsn,"0.1.11"}]}.