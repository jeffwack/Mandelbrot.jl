function treeplot(HC::HyperbolicComponent)
    fig = Figure()
    ax = Axis(fig[1,1])
    htree = HC.htree
    (EdgeList,Nodes) = Mandelbrot.adjlist(htree.adj)
    criticalorbit = orbit(htree.criticalpoint)

    labels = []
    nodecolors = []
    for node in Nodes
        firstchar = node.items[1]
        if firstchar == Mandelbrot.KneadingSymbol('*')
            push!(nodecolors,"black")
        elseif firstchar == Mandelbrot.KneadingSymbol('A') #we are fully in one of the 4 regions
            if HC.onezero[node] == Mandelbrot.Digit{2}(0)
                push!(nodecolors,"blue")
            elseif HC.onezero[node] === nothing
                push!(nodecolors,"turquoise")
            elseif HC.onezero[node] == Mandelbrot.Digit{2}(1)
                push!(nodecolors,"green")
            end
        elseif firstchar == Mandelbrot.KneadingSymbol('B')
            if HC.onezero[node] == Mandelbrot.Digit{2}(0)
                push!(nodecolors,"red")
            elseif HC.onezero[node] === nothing
                push!(nodecolors,"orangered2")
            elseif HC.onezero[node] == Mandelbrot.Digit{2}(1)
                push!(nodecolors,"orange")
            end
        end
    end

    for node in Nodes
        idx = findall(x->x==node, criticalorbit.items)
        if isempty(idx)
            push!(labels,Pair(node,repr("text/plain",node)))
        else
            push!(labels,Pair(node,string(idx[1]-criticalorbit.preperiod-1)))
        end
    end

    zvalues = [HC.vertices[node] for node in Nodes]

    pos = Point.(real.(zvalues),imag.(zvalues)) 

    colorsforinterior = ["red","blue","green","orange"]

    for (ii,p) in enumerate(EdgeList)
        for n in p
            cmplxedge = HC.edges[Set([Nodes[ii],Nodes[n]])][2]
            realedge = Point.(real.(cmplxedge),imag.(cmplxedge)) 
            if nodecolors[ii] in colorsforinterior 
                col = nodecolors[ii]
            elseif nodecolors[n] in colorsforinterior
                col = nodecolors[n]
            elseif nodecolors[ii] !== "black" 
                col = nodecolors[ii]
            elseif nodecolors[n] !== "black" 
                col = nodecolors[n]
            end
            lines!(ax,realedge,color = col,linewidth = 1,transparency = true,overdraw = true)
        end
    end

    julia = Mandelbrot.inverseiterate(HC.parameter,20)
    scatter!(ax,real(julia),imag(julia),markersize = 1,color = "black")


    rays = collect(values(HC.rays))
    n = length(rays)
    for (j ,ray) in enumerate(rays)
        lines!(ax,real(ray),imag(ray),color = get(ColorSchemes.rainbow, float(j)/float(n)))
    end

    scatter!(ax,pos,color = nodecolors)
    tex = [node[2] for node in labels]
    text!(ax,pos,text = tex)
    limits!(-2,2,-2,2)
    return fig
end

function treeplot(theta::Rational)
    return treeplot(HyperbolicComponent(theta))
end

function plottree!(scene, H::HubbardTree)

    (E, nodes) = adjlist(H.adj)
    root = H.zero
    
    criticalorbit = orbit(root)
    
    labels = []
   
    for node in nodes
        idx = findall(x->x==node, criticalorbit.items)
        if isempty(idx)
            push!(labels,Pair(node,repr("text/plain",node)))
        else
            push!(labels,Pair(node,string(idx[1]-criticalorbit.preperiod-1)))
        end
    end

    rootindex = findall(x->x==root,nodes)[1]

    pos = generationposition(E,rootindex)

    for (ii,p) in enumerate(E)
        for n in p
            lines!(scene,[pos[ii],pos[n]],linewidth = 1)
        end
    end

    scatter!(scene,pos)
    tex = [node[2] for node in labels]
    text!(scene,pos,text = tex)
    return scene
end


function generationposition(E,root)
    T = [[root],E[root]]
    
    nadded = 1 + length(T[2])
    n = length(E)

    while nadded < n
        parents = T[end]
        children = []
        for parent in parents
            #cycle E[parent] so that the grandparent is in the last position
            s = findone(x-> x in T[end-1], E[parent])
            for u in circshift(E[parent],-s)
                if !(u in T[end-1])
                    push!(children,u)
                end
            end
        end
        push!(T,children)
        nadded += length(children)
    end
    Ngens = length(T)

    X = zeros(Float64,n) 
    Y = zeros(Float64,n)
    
    for (gen,vertices) in enumerate(T)
        k = length(vertices)
        for (ii,u) in enumerate(vertices)
            X[u] = 2*ii/(k+1) -1
            Y[u] = 2*(1 - gen/(Ngens+1))-1
        end
    end

    return Point.(X,Y)
end


function plotedges!(scene,edgevectors)
    for edge in edgevectors
        line = edge[2][2]
        lines!(scene,real.(line)/2,imag(line)/2,color = "black")
    end
    return scene
end

function plotedges(edgevectors)
    scene = Scene(size=(1000,1000),aspect = 1)
    return plotedges!(scene,edgevectors)
end

function embedanim(AIA::AngledInternalAddress,frames)
    OHT = OrientedHubbardTree(AIA)
    (E,c) = standardedges(OHT)

    edgelist = [E]
    for ii in 1:frames
        E = refinetree(OHT,c,E)
        push!(edgelist,E)
    end

    scene = Scene(size=(1000,1000),aspect = 1)
    record(scene,"embedding.gif",1:frames,framerate = 3) do ii
        empty!(scene)
        plotedges!(scene,edgelist[ii])
    end
end

function embedanim(angle::Rational,frames)
    AIA = AngledInternalAddress(angle)
    return embedanim(AIA,frames)
end

function showtree!(scene,angle::Rational)
    E = refinedtree(angle,8)
    return plotedges!(scene,E)
end

function showtree(angle::Rational)
    scene = Scene(size=(500,500))
    return showtree!(scene, angle)
end
