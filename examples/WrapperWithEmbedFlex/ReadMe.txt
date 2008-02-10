Read Me:
This example is using Wrapper as a main container and loads a compiled flex element into itself. 
To make this work correctly you need to set the background or application node in your xml to be a fixed size so that it isn't basing it's size off of the whole window of stage width. 
Then in you css make sure you set overflow: hidden so that the flex element doesn't resize the Wrapper element. 
You should be able to load any Flex Project into Wrapper this way. There is also a project loading Wrapper into Flex. Both of these method can be used together also. 