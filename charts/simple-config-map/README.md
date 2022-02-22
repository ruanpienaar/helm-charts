helm create simple-config-map
helm install pink-elephant ./simple-config-map --debug
helm get manifest pink-elephant
