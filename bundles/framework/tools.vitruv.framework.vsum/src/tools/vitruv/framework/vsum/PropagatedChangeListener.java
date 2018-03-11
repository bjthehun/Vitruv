package tools.vitruv.framework.vsum;

import java.util.List;

import tools.vitruv.framework.change.description.PropagatedChange;
import tools.vitruv.framework.domains.VitruvDomain;

/**
 * The {@link PropagatedChangeListener} is the interface used to communicate with the change
 * visualization.
 *
 * @author Andreas Loeffler
 */
public interface PropagatedChangeListener {

    /**
     * Whenever changes are made, they must be posted with this method to the visualization-listener.
     *
     * @param virtualModelName
     *            The name of the virtual model. Equal names group results together
     * @param sourceDomain
     *            The sourceDomain, may be null
     * @param targetDomain
     *            The targetDomain, may be null
     * @param propagationResult
     *            The results to visualize
     */
    void postChanges(String virtualModelName, VitruvDomain sourceDomain, VitruvDomain targetDomain,
            List<PropagatedChange> propagationResult);

}
